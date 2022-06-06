#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.ustc.edu.cn" \
    -t tangramor/nginx-php8-fpm:php8.1.6_node18.2.0 .
