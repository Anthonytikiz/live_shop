# 1️⃣ Image PHP + extensions
FROM php:8.2-apache

# Installer dépendances système et PHP
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev zip \
    && docker-php-ext-install intl pdo pdo_mysql zip opcache \
    && a2enmod rewrite

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Autoriser Composer en root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copier seulement les fichiers de dépendances pour profiter du cache Docker
COPY composer.json composer.lock ./

# Installer les dépendances SANS scripts
RUN composer install --no-dev --no-scripts --optimize-autoloader --no-interaction

# Copier tout le code du projet
COPY . .

# Exécuter manuellement les commandes Symfony nécessaires
RUN php bin/console cache:clear --env=prod || true
RUN php bin/console assets:install public || true

# Droits pour Apache
RUN chown -R www-data:www-data var/

# Exposer le port HTTP que Render détectera
EXPOSE 80

# Lancer Apache en avant-plan
CMD ["apache2-foreground"]
