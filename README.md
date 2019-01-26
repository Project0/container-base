# RSPAMD docker image

see [Rspamd](https://rspamd.com/) for more details

## Configuration

This Rspamd docker container ships already well defined [default configurations](https://github.com/rspamd/rspamd/tree/master/conf/modules.d) from the upstream project. 

To adjust/extend configuration (file), settings can be provided as JSON text via environment variables.

Rspamd supports the json like [universal configuration language](https://rspamd.com/doc/configuration/ucl.html) which is used to generate the configuration files

### RSPAMD_INC_name - Main Configuration

Writes `<name>.inc` (main) configuration files which will be included by the main config per setting.

`RSPAMD_INC_LOGGING='{"type":"console", "level:"info"}'`: overrides the setting of the logging.inc
`RSPAMD_INC_WORKER_NORMAL='{"bind_socket": "*:11333", "enable_password": "$2$jhwxfjmciwauo8m9uc9brhgah6ojocro$zc84ur8kpw65nzs89d4ump6i9crt7yxu3swj4poqu5ijgqj6gygb"}'`: sets the listener for the web interface and password `test`

### RSPAMD_CONF_module - Module configuration

Writes `<module>.conf` (module) configuration files which will be included by the config per module.

`RSPAMD_CONF_REDIS='{"servers":"10.0.0.1"}'`: sets and enable the caching with redis server
