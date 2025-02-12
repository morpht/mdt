<?php

/**
 * @file
 * Settings for live environment.
 */

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
 *
 * Since Pantheon for all environments has zend.assertions=1, which goes against
 * Drupal recommendations, let's use this piece from Drupal core sample.
 */
assert_options(ASSERT_ACTIVE, FALSE);

$config['config_split.config_split.dev']['status'] = FALSE;
$config['config_split.config_split.local']['status'] = FALSE;
$config['config_split.config_split.test']['status'] = FALSE;
$config['config_split.config_split.prod']['status'] = TRUE;
