FROM project0de/base-devel:amzn2 AS builder

ENV DESTDIR /build
WORKDIR /src

ARG RSPAMD_VERSION=1.9.4
ARG RSPAMD_REPO=https://github.com/rspamd/rspamd.git

ARG LUJAIT_VERSION=2.0.5
ARG RAGEL_VERSION=6.10

ADD http://luajit.org/download/LuaJIT-${LUJAIT_VERSION}.tar.gz /src/luajit.tar.gz
ADD http://www.colm.net/files/ragel/ragel-${RAGEL_VERSION}.tar.gz /src/ragel.tar.gz

# ragel is only used for buuild
RUN tar xvf ragel.tar.gz \
    && cd ragel-${RAGEL_VERSION} \
    && ./configure \
    && make -j$(nproc) \
    && DESTDIR=/ make install

# faster replacement for lua
RUN tar xvf luajit.tar.gz \
    && cd LuaJIT-${LUJAIT_VERSION} \
    && make -j$(nproc) \
    && DESTDIR=/ make install PREFIX=/usr MULTILIB=lib64 \
    && make install PREFIX=/usr MULTILIB=lib64

RUN yum -y install cmake libevent-devel glib2-devel pcre2-devel libcurl-devel \
       file-static file-devel sqlite-devel libicu-devel openssl-devel\
    && git clone --depth=1 "${RSPAMD_REPO}" --branch=$(git ls-remote --tags --refs -q "${RSPAMD_REPO}" "${RSPAMD_VERSION}*" | tail -n 1 | awk -F/ '{ print $3 }') rspamd \
    && mkdir -p build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr -DRSPAMD_USER='rspamd' -DRSPAMD_GROUP='rspamd' \
      -DCONFDIR=/etc/rspamd -DRUNDIR=/run/rspamd -DLOGDIR=/var/log/rspamd -DDBDIR=/var/lib/rspamd \
      -DENABLE_PCRE2=ON -DENABLE_DB=ON -DENABLE_REDIRECTOR=ON -DENABLE_URL_INCLUDE=ON \
      ../rspamd \
    && make -j$(nproc) \
    && make install

FROM project0de/base:amzn2

ENV RSPAMD_USER rspamd

# install libary deps and user
RUN yum -y install openssl-libs libevent libicu pcre2 libcurl \
    && yum -y update \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && echo "${RSPAMD_USER}:x:100:100:rspamd user:/var/lib/rspamd:/sbin/nologin" >> /etc/passwd \
    && echo "${RSPAMD_USER}:x:100:" >> /etc/group \
    && mkdir -p /var/lib/rspamd /var/log/rspamd \
    && chown -R "${RSPAMD_USER}:${RSPAMD_USER}" /var/lib/rspamd /var/log/rspamd \
    && chmod 0755 /var/lib/rspamd /var/log/rspamd

COPY --from=builder /build /
COPY entrypoint.sh /entrypoint.sh
COPY etc/ /_etc

RUN chmod a+x /entrypoint.sh \
    && rspamd --version

EXPOSE 11333/tcp 11334/tcp

VOLUME [ "/var/lib/rspamd", "/var/log/rspamd" ]

# tini is required to handle clean shutdown of exim
ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]
CMD [ "rspamd", "-f", "-u", "rspamd", "-g", "rspamd" ]
