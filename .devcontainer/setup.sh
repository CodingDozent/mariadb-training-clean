#!/usr/bin/env bash
set -e

# Warten, bis Codespaces das Workspace-Verzeichnis gemountet hat
while [ ! -d "/workspaces" ] || [ ! -d "/workspaces/$(basename "$PWD")" ]; do
    echo "⏳ Waiting for workspace mount..."
    sleep 1
done


LOGFILE=/tmp/codespace-setup.log
echo "=== Setup started ===" | tee $LOGFILE

log() {
  echo "$1"
  echo "$1" >> $LOGFILE
}

log "Updating package lists..."
sudo apt-get update -y >> $LOGFILE 2>&1

log "Installing base tools..."
sudo apt-get install -y git wget unzip curl lsb-release ca-certificates apt-transport-https >> $LOGFILE 2>&1

log "Installing PHP + mysqli..."
sudo apt-get install -y php php-mysql php-zip php-mbstring php-xml php-curl >> $LOGFILE 2>&1

log "Installing MariaDB..."
sudo apt-get install -y mariadb-server mariadb-client >> $LOGFILE 2>&1

log "Configuring MariaDB..."
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf || true

log "Enabling MariaDB error log..."
sudo mkdir -p /var/log/mysql
sudo touch /var/log/mysql/error.log
sudo chown mysql:mysql /var/log/mysql/error.log

sudo tee /etc/mysql/mariadb.conf.d/99-error-log.cnf >/dev/null <<'EOF'
[mysqld]
log_error = /var/log/mysql/error.log
EOF



log "Starting MariaDB..."
sudo service mariadb start >> $LOGFILE 2>&1
sleep 5

# Warten, bis MariaDB bereit ist
until mysqladmin ping >/dev/null 2>&1; do
    echo "⏳ Waiting for MariaDB..."
    sleep 1
done


log "Setting root password..."
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
EOF

log "Creating training database..."
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS training;" >> $LOGFILE 2>&1

log "Downloading phpMyAdmin..."
wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O /tmp/pma.zip

log "Extracting phpMyAdmin..."
unzip -q /tmp/pma.zip -d /tmp
sudo rm -rf /usr/share/phpmyadmin
sudo mv /tmp/phpMyAdmin-*-all-languages /usr/share/phpmyadmin

log "Preparing phpMyAdmin temp directory..."
sudo mkdir -p /usr/share/phpmyadmin/tmp
sudo chmod 777 /usr/share/phpmyadmin/tmp

log "Creating phpMyAdmin config..."
sudo tee /usr/share/phpmyadmin/config.inc.php >/dev/null <<'EOF'
<?php
$cfg['blowfish_secret'] = 'supersecretblowfishkey1234567890';
$cfg['Servers'][1]['auth_type'] = 'cookie';
$cfg['Servers'][1]['host'] = '127.0.0.1';
$cfg['Servers'][1]['AllowNoPassword'] = false;
EOF

sudo chmod 644 /usr/share/phpmyadmin/config.inc.php
sudo chmod 755 /usr/share/phpmyadmin

log "Creating phpMyAdmin configuration storage..."
mysql -u root -proot < /usr/share/phpmyadmin/sql/create_tables.sql >> $LOGFILE 2>&1

log "Executing init.sql..."
mysql -u root -proot < /workspaces/mariadb-training-clean/init.sql >> $LOGFILE 2>&1


# restart.sh ausführbar machen
chmod +x /workspaces/mariadb-training-clean/restart.sh

log "=== Setup complete ==="
log "MariaDB root password: root"
log "phpMyAdmin running on port 8888"


log "Starting phpMyAdmin on port 8888..."
nohup php -S 0.0.0.0:8888 -t /usr/share/phpmyadmin >/tmp/pma.log 2>&1 &
sleep 2


