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

**Important:** This package needs to be explicitly allowed in your project's `composer.json` to enable scaffolding. You can add this configuration using the following Composer command:

```bash
composer config extra.drupal-scaffold.allowed-packages --merge --json '["morpht/mdt"]'
```

Alternatively, you can manually add it to your project's `composer.json`:

```json
{
    "extra": {
        "drupal-scaffold": {
            "allowed-packages": [
                "morpht/mdt"
            ]
        }
    }
}
```

Without this configuration, the scaffolding features will not work and configuration files will not be copied to your project.

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
