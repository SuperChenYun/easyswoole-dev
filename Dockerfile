FROM php:7.3.12-fpm

MAINTAINER The Easyswoole Dev <itzcy@itzcy.com>

WORKDIR /app

# 安装基础软件
RUN git --version

# 安装composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "echo hash_file('sha384', 'composer-setup.php') . PHP_EOL;" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /usr/local/bin/composer \
 && rm -rf /app/*

# 下载 编译安装 swoole 扩展
RUN curl -L -o /app/swoole_4.4.12.tar.gz https://github.com/swoole/swoole-src/archive/v4.4.12.tar.gz \
 && cd /app \
 && cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \ 
 && tar zxvf swoole_4.4.12.tar.gz \
 && cd swoole-src-4.4.12 \
 && phpize \
 && ./configure --with-php-config=/usr/local/bin/php-config \
    --enable-coroutine \
    --enable-http2  \
    --enable-async-redis \
    --enable-mysqlnd \
 && make && make install \
 && echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20180731/swoole.so" >> /usr/local/etc/php/php.ini \
 && php -m \
 && rm -rf /app/*

# 安装easyswoole
RUN /usr/local/bin/composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && /usr/local/bin/composer require easyswoole/easyswoole && php vendor/easyswoole/easyswoole/bin/easyswoole install

VOLUME ["/app"]

EXPOSE 9051

CMD ["php", "/app/easyswoole", "start"]