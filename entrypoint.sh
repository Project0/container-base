#!/bin/sh
set -e
test -f /dhparam/dh.pem || openssl dhparam "${DOVECOT_DHPARAM_BIT}" > /dhparam/dh.pem
mkdir -p /mail /var/lib/dovecot /etc/dovecot/sieve
gomplate --input-dir /_etc/ --output-dir /etc
chown -R mail:mail /mail /var/lib/dovecot /etc/dovecot/sieve
exec "$@"
