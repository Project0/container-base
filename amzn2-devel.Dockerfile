# Buld image with all development tools installed
# project0de/base-devel:amzn2
FROM project0de/base:amzn2

RUN yum -y groupinstall 'Development Tools' \
    && yum -y install cmake \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY devel/gitconfig /root/.gitconfig