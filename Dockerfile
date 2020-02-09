# Build target docker image
FROM project0de/base:amzn2

ARG ROUNDCUBEMAIL_VERSION=1.4.2

## install lamp
RUN amazon-linux-extras install -y php7.3 \
    && yum -y install \
      php-pdo php-fpm php-mysqlnd php-json php-gd php-xml php-intl php-mbstring php-ldap \
      httpd \
      tar \
    && yum clean all \
    && rm -rf /var/cache/yum

## install roundcube
COPY roundcube-pubkey.asc /tmp/roundcube-pubkey.asc
RUN gpg --import /tmp/roundcube-pubkey.asc \
    && curl -o roundcubemail.tar.gz -fSL https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBEMAIL_VERSION}/roundcubemail-${ROUNDCUBEMAIL_VERSION}-complete.tar.gz \
	  && curl -o roundcubemail.tar.gz.asc -fSL https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBEMAIL_VERSION}/roundcubemail-${ROUNDCUBEMAIL_VERSION}-complete.tar.gz.asc \
    && gpg --batch --verify roundcubemail.tar.gz.asc roundcubemail.tar.gz \
    && tar -xf roundcubemail.tar.gz -C /usr/src/ \
    && mv /usr/src/roundcubemail-${ROUNDCUBEMAIL_VERSION} /usr/src/roundcubemail \
    && ln -sf /usr/src/roundcubemail/public_html /var/www/html/public_html \
    && ln -sf /etc/roundcube/config.inc.php /usr/src/roundcubemail/config/config.inc.php \
    && for i in /usr/src/roundcubemail/plugins/*; do test -f "${i}/config.inc.php.dist" && cp -v "${i}/config.inc.php.dist" "${i}/config.inc.php"; done \
    && chown -R apache:apache /usr/src/roundcubemail \
    && rm -rf roundcubemail.tar.gz roundcubemail.tar.gz.asc /usr/src/roundcubemail/installer ~/.gnup

# copy config templates and entrypoint
COPY entrypoint.sh /entrypoint.sh
COPY etc/ /_etc
RUN chmod a+x /entrypoint.sh

ENV ROUNDCUBEMAIL_DB_DIR=/data/db
ENV ROUNDCUB_TEMP_DIR=/data/tmp

# expose these volumes
VOLUME [ "/data/db", "/data/tmp" ]

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "httpd", "-DFOREGROUND"]