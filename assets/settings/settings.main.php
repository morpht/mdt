<?php

/**
 * @file
 * Main settings file mostly reproducing Pantheon's Drops8.
 */

include DRUPAL_ROOT . '/sites/aliases.php';

/**
 * Load services definition file.
 */
$settings['container_yamls'][] = __DIR__ . '/services.yml';

/**
 * Varnish.
 */
$protocol = 'http://';
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) &&
  $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https'
) {
  $_SERVER['HTTPS'] = 'on';
  $protocol = 'https://';
}

/**
 * Host and $base_url.
 */
$host = $_SERVER['HTTP_HOST'];
$base_url = $protocol . $host;

/**
 * Redirects.
 */
if (!empty($aliases[$base_url]) && PHP_SAPI !== 'cli') {
  $domain = $aliases[$base_url];
  $uri = $_SERVER['REQUEST_URI'];
  header('HTTP/1.0 301 Moved Permanently');
  header("Location: $domain$uri");
  exit();
}

/**
 * Config directory.
 */
$settings['config_sync_directory'] = dirname(DRUPAL_ROOT) . "/config/" . $site;

/**
 * The default list of directories that will be ignored by Drupal's file API.
 *
 * By default ignore node_modules and bower_components folders to avoid issues
 * with common frontend tools and recursive scanning of directories looking for
 * extensions.
 *
 * @see file_scan_directory()
 * @see \Drupal\Core\Extension\ExtensionDiscovery::scanDirectory()
 */
if (empty($settings['file_scan_ignore_directories'])) {
  $settings['file_scan_ignore_directories'] = [
    'node_modules',
    'bower_components',
  ];
}

/**
 * Allow test modules and themes to be installed.
 *
 * Drupal ignores test modules and themes by default for performance reasons.
 * During development it can be useful to install test extensions for debugging
 * purposes.
 */
$settings['extension_discovery_scan_tests'] = FALSE;

/**
 * Include the Pantheon-specific settings file.
 *
 * NB The settings.pantheon.php file makes some changes
 *      that affect all environments that this site
 *      exists in.  Always include this file, even in
 *      a local development environment, to insure that
 *      the site settings remain consistent.
 */
if (isset($_ENV['PANTHEON_ENVIRONMENT'])) {
  include __DIR__ . "/settings.pantheon.php";
}

// Morpht's environment-specific settings on Pantheon.
if (isset($_ENV['PANTHEON_ENVIRONMENT'])) {
  // Pantheon has dev, test, live + multidev.
  $env = $_ENV['PANTHEON_ENVIRONMENT'];
  $env_settings_file = DRUPAL_ROOT . "/sites/$site/settings/settings.{$env}.php";
  // Try settings with current environment name.
  if (file_exists($env_settings_file)) {
    require $env_settings_file;
  }
  else {
    // We are on Pantheon multidev with no settings. Fallback to dev.
    $env = 'dev';
    $env_settings_file = DRUPAL_ROOT . "/sites/$site/settings/settings.{$env}.php";
    if (file_exists($env_settings_file)) {
      require $env_settings_file;
    }
  }
}

/**
 * Lando environment settings.
 */
if (isset($_ENV["LANDO_APP_NAME"])) {
  $path = DRUPAL_ROOT . "/sites/$site/settings/settings.lando.php";
  // Load settings.
  if (!empty($path) && file_exists($path)) {
    require $path;
  }
}

/**
 * Allow final local override.
 */
$path = DRUPAL_ROOT . "/sites/$site/settings/settings.local.php";
if (!empty($path) && file_exists($path)) {
  require $path;
}
