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

/**
 * Assertions.
 *
 * The Drupal project primarily uses runtime assertions to enforce the
 * expectations of the API by failing when incorrect calls are made by code
 * under development.
 *
 * @see http://php.net/assert
 * @see https://www.drupal.org/node/2492225
 *
 * If you are using PHP 7.0 it is strongly recommended that you set
 * zend.assertions=1 in the PHP.ini file (It cannot be changed from .htaccess
 * or runtime) on development machines and to 0 in production.
 *
 * @see https://wiki.php.net/rfc/expectations
 */
assert_options(ASSERT_ACTIVE, TRUE);
\Drupal\Component\Assertion\Handle::register();

$settings['trusted_host_patterns'] = [
  '\.tugboat\.qa$',
];

$settings['skip_permissions_hardening'] = TRUE;
$settings['file_public_path'] = "sites/default/files";
$settings['file_private_path'] = '../files/private';
$settings['file_temporary_path'] = '/tmp';
$config_directories['sync'] = '../files/config/sync';

//$config['stage_file_proxy_origin'] = 'https://assets.lullabot.com';
//$config['stage_file_proxy_origin_dir'] = '/';
//$config['stage_file_proxy_hotlink'] = FALSE;
//$config['stage_file_proxy_use_imagecache_root'] = TRUE;

$config['system.logging']['error_level'] = 'verbose';
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);
$settings['hash_salt'] = hash('sha256', getenv('TUGBOAT_REPO_ID'));
