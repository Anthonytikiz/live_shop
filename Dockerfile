# 1. Image PHP avec extensions nécessaires
FROM php:8.3-fpm

# 2. Installer dépendances système & PHP extensions
RUN apt-get update && apt-get install -y \
    nginx supervisor git unzip libzip-dev libicu-dev libxml2-dev curl \
    && docker-php-ext-install intl pdo_mysql zip opcache

# 3. Installer Composer globalement
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 4. Copier le code dans le container
WORKDIR /var/www
COPY . .

# 5. Installer dépendances PHP sans dev, autoload optimisé
# RUN composer install --no-dev --optimize-autoloader
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts


# 6. Configurer permissions Symfony (cache & logs)
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var/cache var/log public

# 7. Copier les fichiers de config pour NGINX et Supervisor (à créer)
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 8. Exposer le port HTTP
EXPOSE 80

# 9. Commande de démarrage (lance Supervisor qui lance NGINX + PHP-FPM)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
