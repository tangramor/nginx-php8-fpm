#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.tuna.tsinghua.edu.cn" \
    -t tangramor/nginx-php8-fpm:php8.4.12_node24.7.0 .
