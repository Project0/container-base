#!/bin/bash
set -euo pipefail

# lookup json vars and transform json to the config file
template='# Set as json value by environment var {{ env.Getenv "_OVERRIDE_LOOKUP_VAR" | strings.ToUpper |  strings.ReplaceAll "-" "_"  }}
{{ env.Getenv "_OVERRIDE_LOOKUP_VAR" | strings.ToUpper |  strings.ReplaceAll "-" "_" | env.Getenv | data.JSON| data.ToJSONPretty "" | strings.TrimPrefix "{" |  strings.TrimSuffix "}" }}'

# build tpl file to process with gomplate
function tpl() {
    # remove extension suffix
    file="/_etc/rspamd/local.d/override.d/${1}"
    name="RSPAMD_${2}_${1%.*}"
    sed -e "s/_OVERRIDE_LOOKUP_VAR/${name}/g" <<< "$template" > "$file"
}

mkdir -p /_etc/rspamd/local.d/override.d/
# create settings/inc template files
find /etc/rspamd/ -maxdepth 1  -iname "*.inc" -type f -printf "%f\n" | while read -r file; do tpl "$file" "INC"; done
# create module/conf template files
find /etc/rspamd/modules.d -maxdepth 1  -iname "*.conf" -type f -printf "%f\n"  | while read -r file; do tpl "$file" "CONF"; done

# process config templates
gomplate --input-dir /_etc/ --output-dir /etc

mkdir -p /var/lib/rspamd /var/log/rspamd
chown -R "${RSPAMD_USER}:${RSPAMD_USER}" /var/lib/rspamd /var/log/rspamd
chmod 0755 /var/lib/rspamd /var/log/rspamd

exec "$@"
