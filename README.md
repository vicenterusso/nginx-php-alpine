# Docker PHP-FPM 7.4.30 & Nginx 1.20 on Alpine Linux
PHP-FPM 7.4.30 & Nginx 1.20 setup for Docker, build on [Alpine Linux](https://www.alpinelinux.org/).

* Built on the lightweight and secure Alpine Linux distribution
* Uses PHP 7.4.30 for better performance, lower CPU usage & memory footprint
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's on-demand PM)
* The servers Nginx, PHP-FPM and supervisord run under a non-privileged user (www) to make it more secure

![nginx 1.20.2](https://img.shields.io/badge/nginx-1.20.2-brightgreen.svg)
![php 7.4.30](https://img.shields.io/badge/php-7.4.30-brightgreen.svg)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)


## Usage

Use the following template

```
version: '3'
services:
    app:
        image: vicenterusso/php-nginx-alpine:v1
        volumes:
            - "./etc/nginx/vhosts:/etc/nginx/conf.d"
            - "./etc/ssl:/var/www/ssl"
            - "./web/projectfolder:/var/www/html"
        ports:
            - "80:8080"
            - "443:4443"   
```
