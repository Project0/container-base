#!/bin/bash
set -euo pipefail

# lookup json vars and transform json to the config file
template='# Set as json value by environment var _OVERRIDE_LOOKUP_VAR
{{ env.Getenv "_OVERRIDE_LOOKUP_VAR" | data.JSON | data.ToJSONPretty "" | strings.TrimPrefix "{" |  strings.TrimSuffix "}" }}'

# build tpl file to process with gomplate
function tpl() {
    # remove extension suffix
    file="/_etc/rspamd/override.d/${1}"
    name="RSPAMD_${1%.*}"
    name=${name/-/_}
    sed -e "s/_OVERRIDE_LOOKUP_VAR/${name^^}/g" <<< "$template" > "$file"
}

# create settings for inc and conf template files
mkdir -p /_etc/rspamd/override.d/
grep -R override.d /etc/rspamd | grep -v '#' | grep -Poe 'LOCAL_CONFDIR/.+(inc|conf)' | grep -Poe '[\w-_]+.(inc|conf)$' | while read -r file; do tpl "$file"; done

# process config templates
gomplate --input-dir /_etc/ --output-dir /etc

mkdir -p /var/lib/rspamd /var/log/rspamd
chown -R "${RSPAMD_USER}:${RSPAMD_USER}" /var/lib/rspamd /var/log/rspamd
chmod 0755 /var/lib/rspamd /var/log/rspamd

exec "$@"
