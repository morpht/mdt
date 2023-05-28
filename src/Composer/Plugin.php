<?php

namespace Morpht\Mdt\Composer;

use Composer\Composer;
use Composer\IO\IOInterface;

/**
 * Composer plugin.
 */
class Plugin implements PluginInterface, EventSubscriberInterface {

  /**
   * Composer.
   *
   * @var \Composer\Composer
   */
  protected $composer;
  /**
   * IO.
   *
   * @var \Composer\IO\IOInterface
   */
  protected $io;

  /**
   * {@inheritDoc}
   */
  public function activate(Composer $composer, IOInterface $io) {
  }

  /**
   * {@inheritDoc}
   */
  public function deactivate(Composer $composer, IOInterface $io) {
  }

  /**
   * {@inheritDoc}
   */
  public function uninstall(Composer $composer, IOInterface $io) {
  }

}
