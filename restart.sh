#!/bin/bash

echo "🔄 Restarting MariaDB and PHP server..."

# MariaDB sauber neu starten
echo "➡️ Starting MariaDB..."
sudo /etc/init.d/mariadb stop >/dev/null 2>&1
sudo /etc/init.d/mariadb start

# PHP Built-In Server neu starten
echo "➡️ Starting PHP Built-In Server on port 8888..."
# Alte Prozesse killen
pkill -f "php -S 0.0.0.0:8888" >/dev/null 2>&1

# Neu starten (im Hintergrund)
php -S 0.0.0.0:8888 -t phpmyadmin >/dev/null 2>&1 &

echo "✅ Services restarted."
