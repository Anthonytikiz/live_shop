FROM php:8.2-apache

# Installer extensions PHP
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev zip \
    && docker-php-ext-install intl pdo pdo_mysql zip opcache \
    && a2enmod rewrite \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf


# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copier tout le projet (y compris .env)
COPY . .

# Config Apache -> DocumentRoot public + accès autorisé
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog /var/log/apache2/error.log\n\
    CustomLog /var/log/apache2/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Installer les dépendances sans scripts pour éviter symfony-cmd
RUN composer install --no-dev --no-scripts --optimize-autoloader --no-interaction

# Créer var/ si manquant et donner les droits
RUN mkdir -p var/cache var/log var/sessions \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Exécuter manuellement les scripts Symfony
RUN php bin/console cache:clear --env=prod || true
RUN php bin/console assets:install public || true

# Environnement de prod
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Exposer le port HTTP pour Render
EXPOSE 80

# Lancer Apache
CMD ["apache2-foreground"]
