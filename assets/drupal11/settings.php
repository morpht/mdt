<?php

/**
 * @file
 * Main Drupal settings file.
 */

$site = 'default';

// Include site specific settings.
require DRUPAL_ROOT . "/sites/$site/settings/settings.main.php";

/* Drupal installation will put hash salt here. Remove it manually. */
