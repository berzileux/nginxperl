![Docker & Nginx & Perl](https://cloud.githubusercontent.com/assets/6241518/4104908/424e46f8-319b-11e4-9a2e-49a8cc49951c.jpg)

**docker-nginx-perl** is a CentOS-based docker container for [Nginx](http://nginx.org) + [Perl](http://www.cpan.org/). It is intended for use with [belabs/ngperlapi](https://github.com/belabs/docker-perlapi).

Nginx 1.9.2 is compiled from source with the below modules enabled:
- http_ssl_module - for HTTPS support
- http_realip_module
- http_addition_module
- http_stub_status_module
- http_dav_module
- http_mp4_module
- http_gunzip_module
- http_gzip_static_module
- http_random_index_module
- http_secure_link_module
- http_image_filter_module
- perl [5.38.0]
- mail
- mail_ssl_module
- ipv6
- pcre
- file-aio
- [nginx-accesskey-v2.0.5](https://github.com/Martchus/nginx-accesskey/archive/refs/tags/v2.0.5.tar.gz)
- [headers-more-nginx-module-v0.35](https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.35.tar.gz)
- [spnego-http-auth-nginx-module](https://github.com/stnoonan/spnego-http-auth-nginx-module) - for Kerberos authentication

# About

This is just a base container for nginx/perl

# Volmes

There are three volumes defined in this image:

- `/var/nginx/www`
- `/etc/config`
- `/opt/nginx-perl/modules`

# Thanks to

[Dylan Lindgren](https://github.com/dylanlindgren/docker-nginx) - For the base example, we copied most of it but retweaked for our purpose. Please drop in to his repo for PHP-FPM reference. For the rest of the README.md

[Anton Cnam](https://github.com/cnam/mock-server) - Gave me some clarity


# Checking the image

docker run --rm -it --entrypoint=/bin/bash nginxperl:latest