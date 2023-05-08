#!/bin/bash

docker build \
    --build-arg APKMIRROR="mirrors.ustc.edu.cn" \
    -f Dockerfile.withoutNodejs \
    -t tangramor/nginx-php8-fpm:php8.2.5_withoutNodejs .
