#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.tuna.tsinghua.edu.cn" \
    -f Dockerfile.withoutNodejs \
    -t tangramor/nginx-php8-fpm:php8.2.7_withoutNodejs .
