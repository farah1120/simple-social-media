#!/bin/sh
set -e

# 1. Folder sistem
mkdir -p bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views
chmod -R 775 bootstrap storage
chown -R www-data:www-data bootstrap storage

# 2. Dependencies
composer install --optimize-autoloader --no-dev --no-interaction
npm install --legacy-peer-deps --no-audit --progress=false
npm run build

# 3. Environment (Hanya setup dasar)
cp .env.example .env || true
php artisan key:generate --force

# 4. JANGAN JALANKAN MIGRASI DI SINI
# Migrasi akan kita jalankan manual nanti setelah kontainer running
echo "Build selesai tanpa migrasi untuk menghindari error koneksi DB."
