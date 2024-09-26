# Étape de construction
FROM grpc/php:8.1 as builder

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

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
FROM grpc/php:8.1

# Copier les extensions et configurations PHP depuis l'étape de construction
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

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