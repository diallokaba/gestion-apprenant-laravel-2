# Étape de construction
FROM php:8.1-fpm as builder

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    libssl-dev \
    libpq-dev \ 
    && rm -rf /var/lib/apt/lists/*

# Installer gRPC
RUN pecl install grpc \
    && docker-php-ext-enable grpc

# Installer les extensions PHP requises pour Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_pgsql zip

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copier les fichiers de dépendances
WORKDIR /app
COPY composer.json composer.lock ./

# Installer les dépendances
RUN composer install --no-dev --no-scripts --no-autoloader

# Étape finale
FROM php:8.1-fpm

# Copier les extensions et configurations PHP depuis l'étape de construction
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Copier Composer dans l'image finale depuis l'étape builder
COPY --from=builder /usr/bin/composer /usr/bin/composer

# Copier l'application
WORKDIR /var/www
COPY . .
COPY --from=builder /app/vendor/ ./vendor/

# Finaliser l'installation de Composer
RUN composer dump-autoload --optimize

# Définir les permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

# Exposer le port 8000 pour le serveur Artisan
EXPOSE 8000

# Lancer le serveur Laravel Artisan
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]