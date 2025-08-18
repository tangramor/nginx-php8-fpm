#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.tuna.tsinghua.edu.cn" \
    -t tangramor/nginx-php8-fpm:php8.4.11_node24.5.0 .
