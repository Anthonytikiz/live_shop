# 1️⃣ Image PHP avec Apache
FROM php:8.2-apache

# 2️⃣ Installer les extensions PHP nécessaires à Symfony
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev zip \
    && docker-php-ext-install intl pdo pdo_mysql zip opcache \
    && a2enmod rewrite

# 3️⃣ Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4️⃣ Config Apache pour Symfony
COPY ./docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf

# 5️⃣ Copier le code Symfony
WORKDIR /var/www/html
COPY . .

# 6️⃣ Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

# 7️⃣ Optimiser Symfony pour la prod
RUN php bin/console cache:clear --env=prod

# 8️⃣ Droits
RUN chown -R www-data:www-data /var/www/html/var

# 9️⃣ Port Apache
EXPOSE 80

CMD ["apache2-foreground"]
