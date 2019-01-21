#!/bin/sh
set -e

mkdir -p /var/lib/clamav
chmod 0755 /var/lib/clamav
chown -R "${CLAMAV_USER}:${CLAMAV_USER}" /var/lib/clamav

# Bootstrap the database if clamav is running for the first time
[ -f /var/lib/main.cvd ] || freshclam --daemon-notify=disabled

# Run the update daemon
freshclam -d -c 6

exec "$@"
