FROM php:8.2-cli

# Install extensions PHP
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev zip \
    && docker-php-ext-install intl zip pdo pdo_mysql

WORKDIR /app

# Autoriser composer en root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copier seulement les fichiers de dépendances pour profiter du cache Docker
COPY composer.json composer.lock ./

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Installer les dépendances SANS scripts
RUN composer install --no-scripts --no-dev --optimize-autoloader --no-interaction

# Copier tout le code du projet
COPY . .

# Maintenant exécuter les scripts une fois que bin/console existe
RUN composer run-script post-install-cmd

# Exposer le port que Render détectera
EXPOSE 80

# Commande de démarrage
CMD ["php", "-S", "0.0.0.0:80", "-t", "public"]
