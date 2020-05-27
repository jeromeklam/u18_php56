# Version 1.0.1

FROM jeromeklam/u18
MAINTAINER Jérôme KLAM, "jeromeklam@free.fr"

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VER 5.6

## Installation de PHP 5.6
RUN apt-get update && apt-get install -y libzmq3-dev
RUN apt-get update && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y php${PHP_VER} php${PHP_VER}-cli php${PHP_VER}-common
RUN apt-get update && apt-get install -y php-mbstring php-mysql php-xml php-pear php-soap
RUN apt-get update && apt-get install -y php-dev php-tidy php-zip php-memcached
RUN apt-get update && apt-get install -y php-curl php-ldap php-gd php-intl php-gmp php-zmq

RUN apt-get update && apt-get install -y php-xdebug php-redis php${PHP_VER}-fpm 

# Supervisor
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/php-fpm.conf

# Standardize PHP executable location
RUN rm -f /etc/alternatives/php && ln -s /usr/bin/php${PHP_VER} /etc/alternatives/php
RUN rm -f /etc/alternatives/phar.phar && ln -s /usr/bin/phar.phar${PHP_VER} /etc/alternatives/phar.phar
RUN rm -f /etc/alternatives/phpize && ln -s /usr/bin/phpize${PHP_VER} /etc/alternatives/phpize
RUN rm -f /usr/sbin/php-fpm && ln -s /usr/sbin/php-fpm${PHP_VER} /usr/sbin/php-fpm
RUN mkdir -p /run/php

# PHP config
COPY docker/php.ini /etc/php/${PHP_VER}/fpm/
COPY docker/www.conf /etc/php/${PHP_VER}/fpm/pool.d/

## Installation de composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
# module dev avec liens
RUN composer global require "jeromeklam/composer-localdev"
RUN composer global update

EXPOSE 9000
EXPOSE 8080

VOLUME ["/var/www/html"]
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-n"]