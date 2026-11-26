FROM php:8.4-cli-alpine

# 最小限のユーティリティを導入
RUN apk add --no-cache \
    git \
    unzip \
    tzdata

# PHP拡張（pdo_mysql, pcntl, redis）を軽量にインストール
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    pdo_mysql \
    pcntl \
    redis

# Composer を公式イメージからコピー
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP CLI 設定
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-custom.ini

WORKDIR /var/www/html

CMD ["sleep", "infinity"]
