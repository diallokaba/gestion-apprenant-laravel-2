# Utiliser une image PHP officielle avec FPM
FROM php:8.1-fpm

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    libonig-dev \
    pkg-config \
    libssl-dev \
    libpq-dev \
    libgrpc-dev \  
    && pecl install grpc \
    && docker-php-ext-enable grpc

# Installer les extensions PHP requises pour Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install pdo_pgsql  # Installation du driver pdo_pgsql

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copier le projet Laravel dans le conteneur
WORKDIR /var/www
COPY . .

# Installer les dépendances PHP, en ignorant les exigences de l'extension gRPC
RUN composer install --optimize-autoloader --no-dev --ignore-platform-req=ext-grpc

# Changer les permissions pour les fichiers Laravel (storage et cache)
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

# Exposer le port 8000 pour le serveur Artisan
EXPOSE 8000

# Lancer le serveur Laravel Artisan
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
