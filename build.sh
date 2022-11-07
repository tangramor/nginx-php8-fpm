#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.ustc.edu.cn" \
    -t tangramor/nginx-php8-fpm:php8.1.12_node19.0.0 .
