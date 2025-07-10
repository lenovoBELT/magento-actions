FROM debian:bullseye

LABEL org.opencontainers.image.source="https://github.com/MAD-I-T/magento-actions"



RUN echo 'deb  http://deb.debian.org/debian  bullseye contrib non-free' >> /etc/apt/sources.list
RUN echo 'deb-src  http://deb.debian.org/debian  bullseye contrib non-free' >> /etc/apt/sources.list


RUN apt-get -y update \
    && apt-get -y install \
    apt-transport-https \
    ca-certificates \
    wget


RUN apt-get -yq install \
    python3-pip\
    python3-setuptools\
    gcc\
    python-dev

RUN wget -O "/etc/apt/trusted.gpg.d/php.gpg" "https://packages.sury.org/php/apt.gpg" \
    && sh -c 'echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list'

RUN apt-get install -f libgd3 -y

RUN apt-get -y update \
    && apt-get -y install \
    git \
    curl \
    php8.3 \
    php8.3-common \
    php8.3-cli \
    php8.3-curl \
    php8.3-dev \
    php8.3-gd \
    php8.3-intl \
    php8.3-mysql \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-xsl \
    php8.3-zip \
    php8.3-xdebug \
    php8.3-soap \
    php8.3-bcmath \
    zip \
    default-mysql-client \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/doc \
    /usr/share/doc-base

RUN curl -LO https://getcomposer.org/composer-stable.phar \
    && mv ./composer-stable.phar ./composer.phar \
    && chmod +x ./composer.phar \
    && mv ./composer.phar /usr/local/bin/composer\
    && php8.3 /usr/local/bin/composer self-update --2

COPY LICENSE README.md /
COPY scripts /opt/scripts
COPY config /opt/config
COPY entrypoint.sh /entrypoint.sh

RUN cd /opt/config/php-deployer/ &&  /usr/bin/php8.3 /usr/local/bin/composer install

RUN  mkdir /opt/magerun/ \
    && cd /opt/magerun/ \
    && curl -sS -O https://files.magerun.net/n98-magerun2-latest.phar \
    && curl -sS -o n98-magerun2-latest.phar.sha256 https://files.magerun.net/sha256.php?file=n98-magerun2-latest.phar \
    && shasum -a 256 -c n98-magerun2-latest.phar.sha256

ENTRYPOINT ["/entrypoint.sh"]
