# Image de base
FROM php:8.3.6-fpm

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    nginx zip git unzip libxml2-dev libxslt-dev \
    libicu-dev libzip-dev && \
    docker-php-ext-install zip intl pdo pdo_mysql opcache && \
    docker-php-ext-configure intl

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir le répertoire de travail
WORKDIR /var/www

# Copier les fichiers du projet
COPY . .

# Installer les dépendances PHP avec Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --ignore-platform-reqs --optimize-autoloader --no-interaction

# Configurer les permissions des répertoires Symfony
RUN mkdir -p var/log var/cache public && \
    chown -R www-data:www-data var/log var/cache public

# Créer le répertoire de log pour php-fpm et définir les permissions
RUN mkdir -p /var/log/php-fpm && chown -R www-data:www-data /var/log/php-fpm

# Copier la configuration NGINX et Supervisor
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD service nginx start && php-fpm --nodaemonize

# Installer Supervisor
RUN apt-get install -y supervisor

# Exposer le port 80
EXPOSE 80

# Lancer Supervisor pour gérer NGINX et PHP-FPM
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
