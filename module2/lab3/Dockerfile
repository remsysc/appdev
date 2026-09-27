FROM php:8.2-fpm
WORKDIR /var/www
COPY . .
RUN apt-get update && apt-get install -y unzip \
    && curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install --no-dev --optimize-autoloader
EXPOSE 9000
CMD ["php-fpm"]
