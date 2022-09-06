#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.ustc.edu.cn" \
    -t tangramor/nginx-php8-fpm:php8.1.10_node18.8.0 .
