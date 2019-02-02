FROM php:7.1-fpm

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends libjpeg-dev libpng-dev ssmtp libpq-dev libmemcached-dev libzip-dev; \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-install gd mysqli opcache zip;

RUN pecl install pecl install xdebug && docker-php-ext-enable xdebug
RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && echo 'include=/usr/local/etc/php/www.conf' >> /usr/local/etc/php/php.ini
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini;

RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini

ADD xdebug.ini /usr/local/etc/php/conf.d
ADD ./www.conf /usr/local/etc/php
