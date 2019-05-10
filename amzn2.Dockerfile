# Build base image
# project0de/base:amzn2
FROM amazonlinux:2

# Add gomplate
ADD https://github.com/hairyhenderson/gomplate/releases/download/v3.4.1/gomplate_linux-amd64-slim /extra/bin/gomplate
# Add tini
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /extra/bin/tini

# update image
RUN yum fs filter languages en \
    && yum fs filter documentation \
    && yum -y update \
    && yum -y reinstall glibc-common \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && chmod a+x /extra/bin/*

ENV PATH="${PATH}:/extra/bin/"
