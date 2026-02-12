#!/bin/bash

echo "🔄 Restarting MariaDB and PHP server..."

# MariaDB sauber neu starten
echo "➡️ Starting MariaDB..."
sudo service mariadb stop
sudo service mariadb start >> /tmp/restart.log 2>&1

# PHP Built-In Server neu starten
echo "➡️ Starting PHP Built-In Server on port 8888..."
# Alte Prozesse killen
pkill -f "php -S 0.0.0.0:8888" >/dev/null 2>&1

# Neu starten (im Hintergrund)
nohup php -S 0.0.0.0:8888 -t /usr/share/phpmyadmin >> /tmp/pma.log 2>&1 &

echo "✅ Services restarted."
