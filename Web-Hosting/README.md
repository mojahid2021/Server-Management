# VPS PHP Web Hosting Setup (Debian)

This script automates the setup of a secure PHP web hosting environment on a Debian VPS.

## ✅ Features

- Apache + PHP + MySQL setup
- phpMyAdmin installation (IP restricted)
- Virtual Host configuration
- phpMyAdmin access control by IP
- MySQL secure installation
- Bash script to create new databases

## 🚀 Usage

### 1. Edit Configuration

Before running, edit these lines in `setup_web_hosting.sh`:

```bash
DOMAIN="yourdomain.com" 
DB_USER="webuser"
DB_PASS="StrongPassword123"
ADMIN_IP="YOUR.IP.ADDRESS.HERE"

## ✅ Features
chmod +x setup_web_hosting.sh
sudo ./setup_web_hosting.sh
