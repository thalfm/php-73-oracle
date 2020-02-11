FROM php:7.3.14-fpm

#Copy drivers ORACLE 18c
COPY oracle-instantclient18.5-basic-18.5.0.0.0-3.x86_64.rpm /tmp/oracle-oci18.rpm
COPY oracle-instantclient18.5-devel-18.5.0.0.0-3.x86_64.rpm /tmp/oracle-oci18-devel.rpm

#Include Oracle Environment Variable - ORACLE 18c
ENV ORACLE_HOME=/usr/lib/oracle/18.5/client64 \
    PATH=$PATH:/usr/lib/oracle/18.5/client64/bin \
    LD_LIBRARY_PATH=/usr/lib/oracle/18.5/client64/lib

RUN apt-get update && apt-get install -y \
    alien
#alien - Oracle 18c
RUN cd /tmp  \
&& alien -i oracle-oci18.rpm oracle-oci18-devel.rpm

#Install libs
RUN apt-get install -y \
        libpq-dev \
        wget \
        unzip \
        libaio1 \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libldap2-dev \
        libldb-dev \
        zlib1g-dev \
        libicu-dev g++ \
        libzip-dev \
        zip \
        && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/lib/oracle/18.5/client64/lib \
        && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/lib/oracle/18.5/client64/lib \
        && docker-php-ext-install -j$(nproc) oci8 pgsql pdo pdo_oci soap gd intl \
        && docker-php-ext-configure zip \
        && docker-php-ext-install zip \
        && pecl install redis && docker-php-ext-enable redis \
        && docker-php-source delete \
        && apt-get remove -y g++ wget alien \
        && apt-get autoremove --purge -y && apt-get autoclean -y && apt-get clean -y \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /tmp/* /var/tmp/*

#Rename php.ini
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"