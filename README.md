# RSPAMD docker image

see [Rspamd](https://rspamd.com/) for more details

## Configuration

This Rspamd docker container ships already well defined [default configurations](https://github.com/rspamd/rspamd/tree/master/conf/modules.d) from the upstream project.

To adjust/extend configuration (file), settings can be provided as JSON text via environment variables.

Rspamd supports the json like [universal configuration language](https://rspamd.com/doc/configuration/ucl.html) which is used to generate the configuration files

### RSPAMD_name - Configuration

Writes `<name>.inc` or `<name>.conf` configuration files which will be included by the main config per setting or module.

#### Examples
`RSPAMD_LOGGING='{"type":"console", "level:"info"}'`: overrides the setting of the logging.inc

`RSPAMD_WORKER_CONTROLLER='{"bind_socket": "*:11333", "enable_password": "$2$jhwxfjmciwauo8m9uc9brhgah6ojocro$zc84ur8kpw65nzs89d4ump6i9crt7yxu3swj4poqu5ijgqj6gygb"}'`: override worker-controller.inc, sets the listener for the web interface and password `test`

`RSPAMD_CONF_REDIS='{"servers":"10.0.0.1"}'`: override redis.conf, sets and enable the caching with redis server
