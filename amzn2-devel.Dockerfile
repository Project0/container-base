# Buld image with all development tools installed
# project0de/base:amzn2-devel
FROM project0de/base:amzn2

RUN yum -y groupinstall 'Development Tools' \
    && yum clean all \
    && rm -rf /var/cache/yum 