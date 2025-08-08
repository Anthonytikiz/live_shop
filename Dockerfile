# Étape 1 : Image PHP avec extensions nécessaires
FROM php:8.2-fpm

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git unzip zip curl libpq-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo pdo_pgsql zip

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Créer le dossier de l'app
WORKDIR /var/www

# Copier tous les fichiers du projet
COPY . .

# 🟢 Ajouter un .env de secours (important pour éviter l'erreur)
COPY .env.docker .env

# Installer les dépendances PHP
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --ignore-platform-reqs --optimize-autoloader --no-interaction

# Donner les bons droits
RUN chown -R www-data:www-data /var/www/var /var/www/vendor

# Exposer le port (optionnel si tu utilises Nginx/Render auto)
EXPOSE 9000

# Commande par défaut
CMD ["php-fpm"]
