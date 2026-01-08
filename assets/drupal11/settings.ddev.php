<?php

/**
 * @file
 * DDEV development override configuration.
 */

$loc_db_name = 'db';
$loc_db_user = 'db';
$loc_db_pass = 'db';
$loc_db_host = 'db';
$loc_db_port = '3306';

$databases = [
  'default' =>
    [
      'default' =>
        [
          'database' => $loc_db_name,
          'username' => $loc_db_user,
          'password' => $loc_db_pass,
          'host' => $loc_db_host,
          'port' => $loc_db_port,
          'driver' => 'mysql',
          'prefix' => '',
        ],
    ],
];

/**
 * Setup files on DDEV.
 */
$settings['file_public_path'] = "sites/$site/files";
$settings['file_private_path'] = "/var/www/html/web/sites/$site/files/private";
$settings["file_temp_path"] = '/tmp';

/**
 * Skip file system permissions hardening on local.
 */
$settings['skip_permissions_hardening'] = TRUE;

/**
 * Access control for update.php script.
 */
$settings['update_free_access'] = TRUE;

/**
 * Enable local development services.
 */
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';

/**
 * Disable Drupal caching.
 */
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';

/**
 * Enable access to rebuild.php.
 *
 * This setting can be enabled to allow Drupal's php and database cached
 * storage to be cleared via the rebuild.php page. Access to this page can also
 * be gained by generating a query string from rebuild_token_calculator.sh and
 * using these parameters in a request to rebuild.php.
 */
$settings['rebuild_access'] = TRUE;

/**
 * Salt for one-time login links, cancel links, form tokens, etc.
 */
$settings['hash_salt'] = 'LOCAL_ONLY';

$config['config_split.config_split.local']['status'] = TRUE;
$config['config_split.config_split.dev']['status'] = FALSE;
$config['config_split.config_split.test']['status'] = FALSE;
$config['config_split.config_split.prod']['status'] = FALSE;
