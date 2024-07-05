#!/bin/bash

docker build \
    -f Dockerfile.withoutNodejs \
    -t tangramor/nginx-php8-fpm:php8.3.8_withoutNodejs .
