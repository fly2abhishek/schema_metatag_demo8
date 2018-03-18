<?php
$databases['default']['default'] = array (
  'database' => 'tugboat',
  'username' => 'tugboat',
  'password' => 'tugboat',
  'prefix' => '',
  'host' => 'mysql',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
$settings['install_profile'] = 'standard';
$config_directories[CONFIG_SYNC_DIRECTORY] = 'sites/default/sync';

// Add trusted host setting.
$settings['trusted_host_patterns'][] = '^.+' . $_SERVER['HTTP_X_TUGBOAT_PREVIEW_TOKEN'] . '\.tugboat\.qa$';

// Settings for a demo site that will generate lots of unused files as content
// is tested and deleted, see https://www.drupal.org/node/2891902.
// Revert to legacy process of marking unused files as temporary.
// Default value is 'false'.
$config['file.settings']['make_unused_managed_files_temporary'] = 'true';

// Delete temporary files after 60 seconds.
// Default value is 21600 (6 hours).
$config['system.file']['temporary_maximum_age'] = 60;
