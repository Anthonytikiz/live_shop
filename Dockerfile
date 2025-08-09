FROM php:8.3-fpm

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    nginx supervisor git unzip libzip-dev libicu-dev libxml2-dev curl \
    && docker-php-ext-install intl pdo_mysql zip opcache \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www

# Copy dependency files first
COPY composer.json composer.lock ./

# Install dependencies with scripts enabled
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Generate autoload files explicitly
RUN composer dump-autoload --optimize

# Copy application code
COPY . .

# Fix permissions
RUN chown -R www-data:www-data /var/www \
    && mkdir -p var/cache var/log \
    && chmod -R 775 var

# Copy config files
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]