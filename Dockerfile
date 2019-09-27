FROM project0de/base-devel:amzn2 as builder

ENV DESTDIR="/build/"
WORKDIR /src

ARG EXIM_VERSION=exim-4.92.2
ARG EXIM_REPO=https://github.com/Exim/exim.git

ARG LIBSPF_VERSION=ec7545ee044ac3f4f6958255778fa43046287386
# use git version, it includes some fixes for build
ADD https://codeload.github.com/shevek/libspf2/tar.gz/${LIBSPF_VERSION} /src/libspf2.tar.gz

# deps
RUN yum install -y openssl-devel mariadb-devel libidn-devel libidn2-devel libdb-devel

# libspf2
RUN tar xvf libspf2.tar.gz \
    && cd libspf2-${LIBSPF_VERSION} \
    && ./configure --prefix=/usr --libdir=/usr/lib64 \
    && make -j$(nproc) \
    && make install

# exim
RUN git get-release "${EXIM_REPO}" "${EXIM_VERSION}" /src/exim 
COPY exim.Makefile /src/exim/src/Local/Makefile
RUN cd /src/exim/src \
    && make -j$(nproc) \
    && install -dm0755 "${DESTDIR}/etc/exim" "${DESTDIR}/usr/bin" "${DESTDIR}/usr/lib/exim/lookups" "${DESTDIR}/var/log/exim"  "${DESTDIR}/var/spool/exim" \
    && for file in $(find /src/exim/src/build* -type f -executable -iname 'e*'); do install -m0755 "$file" "${DESTDIR}/usr/bin/"; done \
    && touch "${DESTDIR}/etc/exim/exim.conf"

# Build target docker image
FROM project0de/base:amzn2

## install libary deps
RUN yum -y install openssl-libs mariadb-libs libidn libidn2 libdb \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && mkdir -p /_etc

# copy config templates and entrypoint
COPY entrypoint.sh /entrypoint.sh
# COPY etc/ /_etc

# setup exim
ENV EXIM_USER exim
COPY --from=builder /build /
RUN echo "${EXIM_USER}:x:79:79:Exim MTA:/var/spool/exim:/sbin/nologin" >> /etc/passwd \
    && echo "${EXIM_USER}:x:79:" >> /etc/group \
    && chmod u+s /usr/bin/exim \
    && chown -R "${EXIM_USER}:${EXIM_USER}" /var/spool/exim /var/log/exim \
    && exim --version \
    && chmod a+x /entrypoint.sh

VOLUME [ "/var/spool/exim", "/var/log/exim" ]

# tini is required to handle clean shutdown of exim (installed in base image)
ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]

# Testing with dns: exim -d+resolver -bh <ip>
CMD [ "exim", "-bdf", "-v", "-q30m" ]
