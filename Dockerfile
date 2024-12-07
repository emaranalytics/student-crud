# Use the official PHP image as base
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache modules
RUN a2enmod rewrite

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Copy Apache configuration
COPY apache2.conf /etc/apache2/sites-available/000-default.conf

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

# Use the PORT environment variable in Apache configuration
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

# Start Apache
CMD ["apache2-foreground"]
