#!/bin/sh
set -euo pipefail

# add primary routed ipv4
# seems not required, if only v6 is set, v4 will automatically used
#if [ -n "${REMOTE_SMTP_INTERFACE}" ]; then
#    export REMOTE_SMTP_INTERFACE="${REMOTE_SMTP_INTERFACE}; $(ip route get 1 | awk '{print $NF;exit}')"
#fi

# gomplate is installed in base image
# exim uses }} pretty strong, lets overwrite the default delimiter
export GOMPLATE_LEFT_DELIM="<{{"
export GOMPLATE_RIGHT_DELIM="}}>"

gomplate --input-dir /_etc/ --output-dir /etc

# Create spool dir so that exim user doesn't have to.
mkdir -p /var/spool/exim /var/log/exim
chown -R "${EXIM_USER}:${EXIM_USER}" /var/spool/exim /var/log/exim
chmod 0755 /var/spool/exim /var/log/exim

exec "$@"
