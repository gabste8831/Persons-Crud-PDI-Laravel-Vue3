# Imagem de produção usada no deploy do Render (ver render.yaml).
# Três etapas: dependências PHP -> build do Vite -> imagem final com Apache.

# 1) Dependências PHP (sem pacotes de desenvolvimento)
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction --ignore-platform-reqs

# 2) Assets do front (Vue + Tailwind). O vendor entra porque o app.css
#    aponta um @source para dentro dele.
FROM node:22-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json .npmrc ./
RUN npm ci
COPY . .
COPY --from=vendor /app/vendor ./vendor
RUN npm run build

# 3) Imagem final: PHP 8.4 + Apache servindo a pasta public/
FROM php:8.4-apache

# pdo_sqlite e mbstring já vêm na imagem oficial; só falta habilitar o rewrite
# (usado pelo public/.htaccess) e apontar o Apache para public/.
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public \
    PORT=8080
RUN a2enmod rewrite \
    && sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf \
    && sed -ri 's!Listen 80!Listen ${PORT}!' /etc/apache2/ports.conf \
    && sed -ri 's!<VirtualHost \*:80>!<VirtualHost *:${PORT}>!' /etc/apache2/sites-available/000-default.conf \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .
COPY --from=vendor /app/vendor ./vendor
COPY --from=assets /app/public/build ./public/build

RUN composer dump-autoload --optimize --no-dev --no-interaction \
    && chmod +x docker/entrypoint.sh \
    && chown -R www-data:www-data storage bootstrap/cache database

EXPOSE 8080
ENTRYPOINT ["docker/entrypoint.sh"]
