# Multi-Site PHP Web Hosting Setup (Debian)

This script automates the setup of **multiple PHP websites** on a single Debian VPS with:

- Apache + PHP + MySQL
- Custom domains for each site
- Separate MySQL databases and users
- phpMyAdmin access (restricted to your IP)

---

## ✅ Features

- Supports **unlimited domains**
- Each site gets its own:
  - Web root (`/var/www/yourdomain.com`)
  - Apache virtual host
  - MySQL database + user
- Shared phpMyAdmin access (IP protected)
- Easy-to-use interactive CLI script

---

## 🛠 Requirements

- Debian 10/11/12+
- Root access to the VPS
- Your domains must be pointed to your server’s IP (via DNS)

---

## 🚀 Usage

### 1. Set Up the Script

Save the script as `multi_site_setup.sh`:

```bash
nano multi_site_setup.sh
# Paste the script content
```

Make it executable:

```bash
chmod +x multi_site_setup.sh
```

### 2. Edit Your IP (for phpMyAdmin security)

Edit the top of the script:

```bash
ADMIN_IP="YOUR.IP.ADDRESS.HERE"
```

To get your IP:

```bash
curl ifconfig.me
```

---

### 3. Run the Script

```bash
sudo ./multi_site_setup.sh
```

You’ll be prompted to enter:
- Domain name (e.g., `example.com`)
- MySQL DB name
- MySQL user & password

After each site setup, you can continue adding more.

---

## 🌐 Access After Setup

- Website URL: `http://yourdomain.com`
- phpMyAdmin (from your IP only): `http://yourdomain.com/phpmyadmin`

---

## 🔐 phpMyAdmin Security

To protect phpMyAdmin from public access, it is restricted via Apache config:

```apache
<Directory /usr/share/phpmyadmin>
    Order deny,allow
    Deny from all
    Allow from YOUR.IP.ADDRESS.HERE
</Directory>
```

Only your IP will be allowed access.

---

## ✅ Example Folder Structure

```
/var/www/
├── example.com/
│   └── index.php
├── testsite.org/
│   └── index.php
```

---

## ➕ Optional Improvements

You can enhance your setup by:

- Adding **Let's Encrypt SSL** (`sudo apt install certbot python3-certbot-apache`)
- Using **`.htpasswd`** for extra admin login security
- Switching to **Nginx** instead of Apache (custom script available)

---

Made with ❤️ for flexible PHP web hosting.
