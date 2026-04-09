FROM ubuntu:22.04

# Menggabungkan install & pembersihan cache dalam satu layer (Sangat Disarankan)
RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y apache2 \
    php npm php-xml php-mbstring php-curl php-mysql php-gd \
    unzip nano curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /var/www/sosmed
WORKDIR /var/www/sosmed

# Pastikan sudah ada file .dockerignore agar tidak menyalin node_modules lokal
ADD . /var/www/sosmed
ADD sosmed.conf /etc/apache2/sites-available/

RUN a2dissite 000-default.conf && a2ensite sosmed.conf

# Folder-folder Laravel yang dibutuhkan
RUN mkdir -p bootstrap/cache \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views && \
    chown -R www-data:www-data /var/www/sosmed && \
    chmod -R 775 /var/www/sosmed

RUN chmod +x install.sh && ./install.sh

EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000
