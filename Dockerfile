FROM php:8.1-apache

# 1. Install extension PHP yang dibutuhkan Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev zlib1g-dev libxml2-dev libzip-dev zip curl unzip \
    && docker-php-ext-install pdo_mysql gd zip

# 2. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Install Node.js & NPM (untuk frontend)
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# 4. Set Working Directory
WORKDIR /var/www/html
COPY . .

# 5. Jalankan install.sh
RUN chmod +x install.sh && ./install.sh

# 6. Setup Apache agar membaca folder /public
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
