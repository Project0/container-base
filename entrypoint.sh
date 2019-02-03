#!/bin/sh
set -e
test -f /dhparam/dh.pem || openssl dhparam 4096 > /dhparam/dh.pem
mkdir -p /mail /var/lib/dovecot /etc/dovecot/sieve
gomplate --input-dir /_etc/ --output-dir /etc
chown -R mail:mail /mail /var/lib/dovecot /etc/dovecot/sieve
exec "$@"
