FROM php:8.2-apache

# Installer extensions PHP
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev zip \
    && docker-php-ext-install intl pdo pdo_mysql zip opcache \
    && a2enmod rewrite

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copier tout le projet (y compris .env)
COPY . .

# Installer les dépendances sans scripts pour éviter symfony-cmd
RUN composer install --no-dev --no-scripts --optimize-autoloader --no-interaction

# Créer var/ si manquant et donner les droits
RUN mkdir -p var/cache var/log var/sessions \
    && chown -R www-data:www-data var/

# Exécuter manuellement les scripts Symfony
RUN php bin/console cache:clear --env=prod || true
RUN php bin/console assets:install public || true

# Exposer le port HTTP pour Render
EXPOSE 80

# Lancer Apache
CMD ["apache2-foreground"]
