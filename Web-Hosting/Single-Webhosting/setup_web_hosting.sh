#!/bin/bash

# === CONFIGURATION ===
DOMAIN="yourdomain.com" # Replace with your domain
WEBROOT="/var/www/$DOMAIN" # Replace with your desired web root
DB_USER="webuser" # Replace with your desired DB user
DB_PASS="StrongPassword123" # Replace with a strong password
ADMIN_IP="YOUR.IP.ADDRESS.HERE" # Replace with your public IP

# === SYSTEM UPDATE ===
echo "=== Updating system ==="
apt update && apt upgrade -y

# === INSTALL WEB SERVER & PHP ===
echo "=== Installing Apache, PHP, MySQL ==="
apt install apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-zip php-gd php-mbstring php-xml php-common unzip curl wget -y

# === INSTALL PHPMYADMIN ===
echo "=== Installing phpMyAdmin ==="
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DB_PASS"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DB_PASS"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DB_PASS"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
apt install phpmyadmin -y

ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# === SECURE PHPMYADMIN ===
echo "Securing phpMyAdmin with IP restriction..."
cat <<EOF > /etc/apache2/conf-available/phpmyadmin-security.conf
<Directory /usr/share/phpmyadmin>
    Order deny,allow
    Deny from all
    Allow from $ADMIN_IP
</Directory>
EOF

a2enconf phpmyadmin-security
systemctl reload apache2

# === CREATE WEB ROOT & TEST PAGE ===
echo "=== Creating web root ==="
mkdir -p "$WEBROOT"
echo "<?php phpinfo(); ?>" > "$WEBROOT/index.php"

# === CREATE APACHE VIRTUAL HOST ===
echo "=== Creating Apache Virtual Host ==="
cat <<EOF > /etc/apache2/sites-available/$DOMAIN.conf
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot $WEBROOT

    <Directory $WEBROOT>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined
</VirtualHost>
EOF

a2ensite "$DOMAIN.conf"
a2enmod rewrite
systemctl reload apache2

# === SECURE MYSQL ===
echo "=== Securing MySQL ==="
/usr/bin/mysql_secure_installation <<EOF

y
$DB_PASS
$DB_PASS
y
y
y
y
EOF

# === CREATE DB CREATION SCRIPT ===
echo "=== Creating MySQL DB Creation Script ==="
cat <<'EOD' > /usr/local/bin/create_mysql_db.sh
#!/bin/bash

read -p "Enter database name: " dbname
read -p "Enter database user: " dbuser
read -s -p "Enter password for user '$dbuser': " dbpass
echo

mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE $dbname;
CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Database $dbname and user $dbuser created."
EOD

chmod +x /usr/local/bin/create_mysql_db.sh

# === FINISHED ===
echo "=== Done! ==="
echo "Site root: http://$DOMAIN"
echo "phpMyAdmin (accessible only from $ADMIN_IP): http://$DOMAIN/phpmyadmin"
echo "To create DB later: run 'create_mysql_db.sh'"
