# ... [keep previous setup]

# Copy dependency files
COPY composer.json composer.lock symfony.lock ./

# Install dependencies with scripts
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Manually generate runtime file
RUN php vendor/bin/runtime get --current --output=/var/www/vendor/autoload_runtime.php

# Verify file exists
RUN if [ ! -f /var/www/vendor/autoload_runtime.php ]; then echo "ERROR: autoload_runtime.php not generated!"; exit 1; fi

# Copy application code
COPY . .

# ... [keep rest of Dockerfile]