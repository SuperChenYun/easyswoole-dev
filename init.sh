#!/bin/bash

if [ ! -e /app/easyswoole ];then
    echo "Init EasySwoole "
    cd /app && /usr/bin/composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && /usr/bin/composer require easyswoole/easyswoole && php vendor/easyswoole/easyswoole/bin/easyswoole install
    cd /app && chown -R root /app
fi
