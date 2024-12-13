# Use the official PHP image with FPM
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Copy .env file
COPY .env /var/www/.env

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Set permissions for storage and bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Install dependencies
RUN composer install --optimize-autoloader --no-dev

# Generate key
RUN php artisan key:generate

# Optimize Laravel
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Create SQLite database
RUN touch database/database.sqlite
RUN chmod 664 database/database.sqlite
RUN chown www-data:www-data database/database.sqlite

# Run migrations
RUN php artisan migrate --force

# Change ownership of the entire application
RUN chown -R www-data:www-data /var/www

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8080
EXPOSE 8080

# Start Nginx and PHP-FPM
CMD service nginx start && php-fpm
