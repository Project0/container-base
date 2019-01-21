FROM project0de/base-devel:amzn2 AS builder

ENV DESTDIR /build
WORKDIR /src

ARG CLAMAV_VERSION=0.101.1
ARG CLAMAV_REPO=https://github.com/Cisco-Talos/clamav-devel.git

RUN yum -y install pcre2-devel libcurl-devel openssl-devel \
    && git get-release "${CLAMAV_REPO}" "clamav-${CLAMAV_VERSION}*" clamav \
    && cd clamav \
    && ./configure --enable-shared=yes --enable-static=no --prefix=/usr --sysconfdir=/etc/clamav \
    && make -j$(nproc) \
    && make install

FROM project0de/base:amzn2

ENV CLAMAV_USER clamav

# install libary deps and user
RUN yum -y install openssl-libs pcre2 libcurl \
    && yum -y update \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && echo "${CLAMAV_USER}:x:100:100:rspamd user:/var/lib/clamav:/sbin/nologin" >> /etc/passwd \
    && echo "${CLAMAV_USER}:x:100:" >> /etc/group \
    && mkdir -p /var/lib/clamav /var/run/clamav \
    && chown -R "${CLAMAV_USER}:${CLAMAV_USER}" /var/lib/clamav /var/run/clamav \
    && chmod 0755 /var/lib/clamav /var/run/clamav

COPY --from=builder /build /
COPY entrypoint.sh /entrypoint.sh
COPY etc/ /etc

RUN chmod a+x /entrypoint.sh \
    && clamav-config --version

VOLUME [ "/var/lib/clamav" ]

EXPOSE 3310/tcp

# tini is required to handle clean shutdown
ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]
CMD [ "clamd" ]
