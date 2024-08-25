# Etapa 1: Construir a imagem com Composer
FROM composer:latest AS composer

# Definir o diretório de trabalho
WORKDIR /app

# Copiar o arquivo composer.json e composer.lock
COPY composer.json composer.lock ./

# Instalar as dependências
RUN composer install --no-dev --optimize-autoloader || true

# Etapa 2: Criar a imagem final
FROM php:8.1-fpm

# Instalar dependências do sistema e extensões PHP necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libonig-dev git unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Definir o diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos da etapa de construção do Composer
COPY --from=composer /app /var/www/html

# Copiar o restante dos arquivos
COPY . .

# Expor a porta 9000 e iniciar o PHP-FPM
EXPOSE 9000
CMD ["php-fpm"]
