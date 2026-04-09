#!/bin/sh
set -e

# 1. Membuat folder sistem Laravel yang diperlukan
mkdir -p bootstrap/cache \
         storage/framework/cache \
         storage/framework/sessions \
         storage/framework/views

# 2. Mengatur izin folder
chown -R www-data:www-data bootstrap storage || true
chmod -R 775 bootstrap storage || true

# 3. Instalasi library (Frontend & Backend)
# Ganti "npm run dev" menjadi "npm run build"
npm install --legacy-peer-deps --no-audit --progress=false
npm run build
composer install --optimize-autoloader --no-dev --no-interaction

# 4. Konfigurasi Environment
cp .env.example .env || true
php artisan key:generate

# 5. Mengatur koneksi Database
# Gunakan nama container "mysql" daripada IP statis agar lebih stabil
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql/g' .env
sed -i 's/DB_DATABASE=laravel/DB_DATABASE=social_media/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env

# 6. Jeda Waktu & Eksekusi Database
# Migrasi biasanya dilakukan SAAT RUNTIME, tapi jika ingin saat build:
echo "Menunggu MySQL..."
sleep 10
php artisan migrate --force || echo "Migrasi gagal, mungkin DB belum siap. Lewati..."
