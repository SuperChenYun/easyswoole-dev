### Quick Start
```
docker run -d -p 9501:9501 -v /home/easyswoole_app:/app easyswoole_dev:7.3.12_4.4.12
```

### Custom environment

> Change Dockerfile
```
FROM centos:latest

LABEL maintainer="The Easyswoole Dev <itzcy@itzcy.com>"

WORKDIR /app
# 安装常用软件
RUN yum install -y curl wget zip zlib openssl make openssl-devel gcc glibc-headers gcc-c++ libxml2 libxml2-devel libpng libpng-devel libzip libzip-devel autoconf \
 && yum clean all

# 安装PHP7.3.12 配置PHP7.3.12
RUN wget -O /app/php-7.3.12.tar.gz https://www.php.net/distributions/php-7.3.12.tar.gz \
 && tar zxvf php-7.3.12.tar.gz \
 && cd php-7.3.12 \
 && ./configure --prefix=/usr/local/php \ 
   --with-config-file-path=/usr/local/php/etc \
   --enable-bcmath \
   --enable-mbstring \
   --with-gd \
   --with-openssl \
   --with-xmlrpc \
   --with-mysqli \
   --with-pdo-mysql \
   --enable-zip \
   --without-pear \
 && make -j4 \
 && make install \
 && mkdir /usr/local/php/etc/ \
 && cp ./php.ini-development /usr/local/php/etc/php.ini \ 
 && ln -s /usr/local/php/bin/php /usr/bin/php \
 && ln -s /usr/local/php/bin/php-config /usr/bin/php-config \
 && ln -s /usr/local/php/bin/phpize /usr/bin/phpize \
 && rm -rf /app/* \
 && php -v

# 安装composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "echo hash_file('sha384', 'composer-setup.php') . PHP_EOL;" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /usr/local/php/bin/composer \
 && ln -s /usr/local/php/bin/composer /usr/bin/composer \
 && rm -rf /app/*

# 下载 编译安装 swoole 扩展
RUN wget -O /app/swoole_4.4.12.tar.gz  https://github.com/swoole/swoole-src/archive/v4.4.12.tar.gz \
 && cd /app \
 && tar zxvf swoole_4.4.12.tar.gz \
 && cd swoole-src-4.4.12 \
 && phpize \
 && ./configure --with-php-config=/usr/bin/php-config \
    --enable-coroutine \
    --enable-http2  \
    --enable-async-redis \
    --enable-mysqlnd \
 && make -j4 \
 && make install \
 && echo "extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20180731/swoole.so" >> /usr/local/php/etc/php.ini \
 && php -m \
 && rm -rf /app/*

VOLUME ["/app"]

EXPOSE 9501

# 初始化easyswoole或启动
COPY ./init.sh /init.sh

CMD bash /init.sh && php /app/easyswoole start

```

### Docker下开发
可以单独映射一个宿主机目录到Docker容器当中，然后根据easyswoole按照文档 http://www.easyswoole.com/Introduction/install.html 在 自定义映射的Docker容器目录中重新安装easyswoole。安装好后即可在宿主机中开发，docker中同步测试运行。

注意，在部分环境下，例如win10的docker环境中，不可把虚拟机共享目录作为EasySwoole的Temp目录，否则会因为权限不足无法创建socket，产生报错：listen xxxxxx.sock fail， 为此可以手动在dev.php配置文件里把Temp目录改为其他路径即可,如：'/Tmp'
