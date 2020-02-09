<?php
$config['des_key'] = '{{ random.AlphaNum 24 }}';
$config['db_dsnw'] = 'sqlite:////{{ Env.ROUNDCUBEMAIL_DB_DIR }}/sqlite.db?mode=0646';
$config['log_driver'] = 'stdout';

$config['default_host'] = 'localhost';
$config['defaukt_port'] = '143';
$config['smtp_server'] = 'localhost';
$config['smtp_port'] = '587';

$config['skin'] = 'larry';
$config['plugins'] = ['archive', 'zipdownload'];
$config['zipdownload_selection'] = true;

# every config can be set or overwritten by env var ROUNDCUBE_<UPPERCASE_CONFIG>