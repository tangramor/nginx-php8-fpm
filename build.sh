#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.tuna.tsinghua.edu.cn" \
    -t tangramor/nginx-php8-fpm:php8.4.10_node24.3.0 .
