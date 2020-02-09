FROM project0de/base-devel:amzn2 AS builder

ENV DESTDIR /build
WORKDIR /src

ARG DOVECOT_VERSION=2.3.9.2
ARG DOVECOT_REPO=https://github.com/dovecot/core.git

ARG LIBSODIUM_VERSION=1.0.18
ARG LIBSODIUM_REPO=https://github.com/jedisct1/libsodium.git

ARG PIGENHOLE_REPO=https://github.com/dovecot/pigeonhole.git
ARG PIGENHOLE_VERSION=0.5.9

RUN yum -y install wget which  openssl-devel mariadb-devel postgresql-devel openldap-devel krb5-devel pam-devel \
      sqlite-devel bzip2-devel zlib-devel lz4-devel xz-devel \
      lua-devel clucene-core-devel expat-devel libexttextcat-devel libcap-devel libicu-devel tcp_wrappers-devel

RUN git get-release "${LIBSODIUM_REPO}" "${LIBSODIUM_VERSION}" /src/libsodium \
    && cd /src/libsodium \
    && ./autogen.sh \
    && ./configure --prefix=/usr --libdir=/usr/lib64 \
    && make -j$(nproc) \
    && make install \
    && DESTDIR=/build make install

RUN git get-release "${DOVECOT_REPO}" "${DOVECOT_VERSION}" /src/dovecot \
    && cd /src/dovecot \
    && ./autogen.sh \
    && PANDOC=false \
      ./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --with-rundir=/run/dovecot \
      --enable-maintainer-mode --disable-static --without-docs \
      --with-ssl=openssl --with-shared-libs \
      --with-zlib --with-bzlib --with-lzma --with-lz4 \
      --with-libcap --with-libwrap --with-lua \
      --with-lucene --with-solr --with-textcat --with-icu \
      --with-sql --with-ldap --with-pgsql --with-mysql --with-sqlite \
      --with-shadow --with-pam --with-gssapi \
    && make -j$(nproc) \
    && DESTDIR=/build make install

RUN git get-release "${PIGENHOLE_REPO}" "${PIGENHOLE_VERSION}" /src/pigenhole \
    && cd /src/pigenhole \
    && ./autogen.sh \
    && ./configure --prefix=/usr --libdir=/usr/lib64 --with-unfinished-features --disable-static --without-docs \
      --with-managesieve --with-ldap=yes --with-dovecot=/src/dovecot/ \
    && make -j$(nproc) \
    && DESTDIR=/build make install

# cleanup
RUN find /build -iname '*.la' -delete -o -iname *'*.a' -delete \
    && rm -rf /build/usr/include

FROM project0de/base:amzn2

ENV DOVECOT_DHPARAM_BIT=4096

COPY --from=builder /build /
COPY entrypoint.sh /entrypoint.sh

RUN yum install -y openssl openssl-libs mariadb-libs postgresql-libs sqlite openldap \
      krb5-libs pam bzip2 zlib lz4 libicu libexttextcat libcap tcp_wrappers-libs clucene-core expat \
    && yum -y update \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && install -d -o mail -g mail -m 0755 /var/lib/dovecot /mail /dhparam \
    && echo "dovecot:x:101:101:mail user:/var/lib/dovecot:/sbin/nologin" >> /etc/passwd \
    && echo "dovecot:x:101:" >> /etc/group \
    && echo "dovenull:x:102:102:mail user:/var/lib/dovecot:/sbin/nologin" >> /etc/passwd \
    && echo "dovenull:x:102:" >> /etc/group \
    && chmod a+x /entrypoint.sh \
    && mkdir -p /_etc /etc/dovecot \
    && touch /etc/dovecot/dovecot.conf \
    && dovecot --version

VOLUME [ "/mail", "/dhparam", "/var/lib/dovecot"]
# tini is required to handle clean shutdown of dovecot
ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]
CMD [ "dovecot", "-c", "/etc/dovecot/dovecot.conf", "-F" ]
