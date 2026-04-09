#!/bin/sh
set -e

# 1. Folder & Izin (Sama dengan Lab)
mkdir -p bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views
chown -R www-data:www-data bootstrap storage || true
chmod -R ug+rwx bootstrap storage || true

# 2. Instalasi (UBAH dev menjadi build agar tidak macet)
npm install --legacy-peer-deps --no-audit --progress=false
npm run build 
composer install --optimize-autoloader

# 3. Konfigurasi (Sama dengan Lab)
cp .env.example .env || true
php artisan key:generate
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env

# 4. Migrasi (Tambahkan "|| true" agar build tidak mati jika DB belum siap)
php artisan migrate --force || echo "DB belum siap, migrasi nanti saja."
php artisan db:seed --force || echo "Seed nanti saja."
