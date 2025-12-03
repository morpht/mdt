# MDT

MDT (Morpht Development and Deployment Tool) provides reusable assets for development and deployment of Drupal 11 applications.

## Features

- Pre-configured Drupal settings files for various environments (local, CI, Pantheon, etc.)
- GitHub Actions workflows for automated deployment
- Lando development environment setup scripts
- Pantheon integration support

## Installation

Add this package to your Drupal project:

```bash
composer require morpht/mdt
```

### Required Configuration

**Important:** This package needs to be explicitly allowed in your project's `composer.json`. You can add this configuration using the following Composer command:

```bash
composer config allow-plugins.morpht/mdt true
```

Alternatively, you can manually add it to your project's `composer.json`:

```json
{
    "config": {
        "allow-plugins": {
            "morpht/mdt": true
        }
    }
}
```

Without this configuration, Composer will prompt you to allow the plugin or the scaffolding features will not work properly.

## Usage

Once installed, MDT will scaffold various configuration files into your project using Drupal's composer-scaffold plugin. These files include:

- Settings files for different environments
- GitHub Actions workflows
- Lando configuration scripts
- Pantheon configuration files

## Requirements

- Drupal 11 or higher
- Composer 2.x

## License

GPL-2.0-or-later
