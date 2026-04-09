#!/bin/sh
set -e

# Izin folder
mkdir -p bootstrap/cache storage/framework/views
chmod -R 775 bootstrap storage
chown -R www-data:www-data bootstrap storage

# Dependencies
composer install --optimize-autoloader --no-interaction
npm install --no-audit
npm run build

# Env
cp .env.example .env || true
php artisan key:generate --force
