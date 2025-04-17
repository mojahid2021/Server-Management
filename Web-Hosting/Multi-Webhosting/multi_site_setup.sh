#!/bin/bash

# === GENERAL CONFIGURATION ===
ADMIN_IP="YOUR.IP.ADDRESS.HERE"  # Replace this with your public IP

# === SYSTEM PREP ===
echo "=== Updating system and installing packages ==="
apt update && apt upgrade -y
apt install apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-zip php-gd php-mbstring php-xml php-common unzip curl wget -y

# === INSTALL PHPMYADMIN ===
echo "=== Installing phpMyAdmin ==="
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
apt install phpmyadmin -y
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# === SECURE PHPMYADMIN ===
cat <<EOF > /etc/apache2/conf-available/phpmyadmin-security.conf
<Directory /usr/share/phpmyadmin>
    Order deny,allow
    Deny from all
    Allow from $ADMIN_IP
</Directory>
EOF
a2enconf phpmyadmin-security
systemctl reload apache2

# === LOOP FOR ADDING MULTIPLE SITES ===
while true; do
    echo ""
    echo "==== New Website Setup ===="

    read -p "Enter domain (e.g. example.com): " DOMAIN
    WEBROOT="/var/www/$DOMAIN"
    read -p "Enter MySQL DB name for $DOMAIN: " DB_NAME
    read -p "Enter MySQL user: " DB_USER
    read -s -p "Enter MySQL password: " DB_PASS
    echo

    echo "=== Setting up web root ==="
    mkdir -p "$WEBROOT"
    echo "<?php phpinfo(); ?>" > "$WEBROOT/index.php"

    echo "=== Creating Apache virtual host ==="
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
    systemctl reload apache2

    echo "=== Creating MySQL DB and user ==="
    mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

    echo "=== $DOMAIN setup complete ==="
    echo "Visit: http://$DOMAIN"
    echo "phpMyAdmin (from $ADMIN_IP only): http://$DOMAIN/phpmyadmin"

    read -p "Do you want to set up another site? (y/n): " CHOICE
    if [[ "$CHOICE" != "y" ]]; then
        break
    fi
done

echo "=== MULTI-WEBSITE SETUP FINISHED ==="
