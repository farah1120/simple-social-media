#!/bin/sh
set -e

# 1. Membuat folder sistem Laravel yang diperlukan
mkdir -p bootstrap/cache \
         storage/framework/cache \
         storage/framework/sessions \
         storage/framework/views

# 2. Mengatur izin folder agar bisa ditulis oleh web server
chown -R www-data:www-data bootstrap storage || true
chmod -R ug+rwx bootstrap storage || true

# 3. Instalasi library (Frontend & Backend)
# Menggunakan --no-audit dan --progress=false untuk menghemat RAM VM
npm install --legacy-peer-deps --no-audit --progress=false
npm run dev
composer install --optimize-autoloader --no-interaction

# 4. Konfigurasi Environment
cp .env.example .env || true
php artisan key:generate

# 5. Mengatur koneksi Database
# Pastikan DB_HOST sesuai dengan IP container mysql (biasanya 172.17.0.2)
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=172.17.0.2/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env

# 6. Jeda Waktu (SANGAT PENTING)
# Memberikan waktu agar MySQL siap menerima koneksi sebelum migrasi dijalankan
echo "Menunggu MySQL siap..."
sleep 20

# 7. Eksekusi Database (Migrasi dan Seed)
php artisan migrate --force
php artisan db:seed --force
