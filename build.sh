#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.tuna.tsinghua.edu.cn" \
    -t tangramor/nginx-php8-fpm:php8.5.2_node25.6.0 .
