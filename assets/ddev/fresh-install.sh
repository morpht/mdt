#!/usr/bin/env bash

# fail on first error, fail on any error in a pipeline:
set -e
set -o pipefail

project_name=$(grep '^name:' /var/www/html/.ddev/config.yaml | cut -f2- -d: | xargs)
remote="live"
aliasplatform="pantheon.$project_name"
site="default"


PARAMS=""
while (("$#")); do
  case "$1" in
  -h | --help)
    echo -e "Usage: ddev fresh-install\t[-h | --help] [-l | --from-local] [-r | --remote \"environment\"]"
    echo -e  ""
    echo -e  "\t-h, --help"
    echo -e  "\t\tPrints out this help text."
    echo -e  ""
    echo -e  "\t-l, --from-local"
    echo -e  "\t\tUse local copies of database dumps when available."
    echo -e  "\t\tFresh database will be fetched as default when this argument is not used."
    echo -e  "\t\tFresh database will be fetched if there is no local copy available."
    echo -e  ""
    echo -e  "\t-nc, --no-cim"
    echo -e  "\t\tSkip config import at the end."
    echo -e  ""
    echo -e  "\t-ns, --no-sanitize"
    echo -e  "\t\tSkip drush sql-sanitize at the end."
    echo -e  ""
    echo -e  "\t-r, --remote"
    echo -e  "\t\tSelects the source environemt for databse and files. Defaults to $remote."
    exit 0
    ;;
  -l | --from-local)
    from_local=true
    shift
    ;;
  -ns | --no-sanitize)
    no_sanitize=true
    shift
    ;;
  -nc | --no-cim)
    no_cim=true
    shift
    ;;
  -r | --remote)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
      remote="$2"
      shift 2
    else
      echo "Error: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  -* | --*=) # unsupported flags
    echo "Error: Unsupported flag $1. Use --help to print information about using this script." >&2
    exit 1
    ;;
  *) # preserve positional arguments
    PARAMS="$PARAMS $1"
    shift
    ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

## Start filling up local sites.
composer install

echo "# Processing: $site:"

# This is mainly to discover SSH key issues early.
echo "Make sure $remote site is ready: drush @$aliasplatform.$remote status"
drush @$aliasplatform.$remote status

# This is mainly to check that local DB credentials line up and the site is ready for DB.
echo "Make sure local site is ready: drush @$aliasplatform.ddev status"
drush @$aliasplatform.ddev status || echo "WARNING: Local site is NOT ready, but let's continue anyway..."

echo "Make sure we can connect to the local DB via drush, otherwise there is no point to continue:"
echo "SHOW STATUS LIKE 'Uptime';" | drush @$aliasplatform.ddev sqlc > /dev/null
echo "   successfully connected to the local DB."

echo "* Fresh copy of settings.local.php"
if [ ! -f "/var/www/html/web/sites/$site/settings/settings.local.php" ]; then
  if [ -d "/var/www/html/web/sites/$site/settings" ]; then
    cp -TRv /var/www/html/.ddev/templates/settings.local.php /var/www/html/web/sites/$site/settings/settings.local.php
  fi
fi

echo "* Make sure files directory is ready."
mkdir -p /var/www/html/web/sites/$site/files/private
mkdir -p /var/www/html/web/sites/$site/files/tmp
chmod -R 777 /var/www/html/web/sites/$site/files
# And prepare local directory for database dumps.
mkdir -p /var/www/html/.local_dbs

# Check if local source is preferred.
if [ "$from_local" = true ]; then
  echo "* Existing local DB is preferred. Looking for /var/www/html/.local_dbs/$remote.sql..."
  if [ -f "/var/www/html/.local_dbs/$remote.sql" ]; then
    echo "* Found /var/www/html/.local_dbs/$remote.sql. Importing..."
  else
    echo "* Local copy at /var/www/html/.local_dbs/$remote.sql. not found. Trying to get one from $remote..."
    echo "* drush @$aliasplatform.$remote sql-dump --structure-tables-key=common | pv > /var/www/html/.local_dbs/$remote.sql"
    drush @$aliasplatform.$remote sql-dump --structure-tables-key=common | pv > /var/www/html/.local_dbs/$remote.sql
  fi
else
  echo "* Fresh DB dump from $remote is preferred. Saving it to /var/www/html/.local_dbs/$remote.sql for later use."
  echo "* drush @$aliasplatform.$remote sql-dump --structure-tables-key=common | pv > /var/www/html/.local_dbs/$remote.sql"
  drush @$aliasplatform.$remote sql-dump --structure-tables-key=common | pv > /var/www/html/.local_dbs/$remote.sql
fi

echo "Wipe local DB: drush @$aliasplatform.ddev sql-drop -y"
drush @$aliasplatform.ddev sql-drop -y

dump_size=$(ls -l /var/www/html/.local_dbs/$remote.sql | awk '{ print $5 }')
echo "Import DB: cat /var/www/html/.local_dbs/$remote.sql | pv -s $dump_size | drush @$aliasplatform.ddev sqlc"
cat /var/www/html/.local_dbs/$remote.sql | pv -s $dump_size | drush @$aliasplatform.ddev sqlc

echo "Cache rebuild: drush @$aliasplatform.ddev cr"
drush @$aliasplatform.ddev cr

if [ "$no_sanitize" = true ]; then
  echo "* Skipping drush sql-sanitize."
else
  echo "Sanitize DB: drush @$aliasplatform.ddev sql-sanitize --yes"
  drush @$aliasplatform.ddev sql-sanitize --yes
fi

if [ "$no_cim" = true ]; then
  echo "* Skipping config import."
else
  echo "* Config import."
  echo "* drush @$aliasplatform.ddev config-import --yes"
  drush @$aliasplatform.ddev config-import --yes
fi

echo -e "\n\n"

# Show login links together at the end.
echo "The site is ready. You can now log in:"
drush @$aliasplatform.ddev uli

echo -e "\n\n"
echo "Run following command if you want to download files too:"
echo "ddev drush rsync @$aliasplatform.$remote:%files @$aliasplatform.ddev:%files --verbose"

exit 0
