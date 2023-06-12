#!/usr/bin/env bash

# This helper is for MacOS only.
# It verifies that ${SSH_AUTH_SOCK} is owned by the user's group and is writable.
#
# https://redmine.morpht.com/issues/18814

test "$LANDO_HOST_OS" == "linux" && exit 0
# For Linux, exit as a pass.

if [ "${SSH_AUTH_SOCK}" != "/run/host-services/ssh-auth.sock" ]
then
  echo "ERROR: Unexpected ssh socket path, please contact Marji."
  # Not expected, but don't stop what ever we are doing:
  exit 0
fi

if [ "${LANDO_WEBROOT_GROUP}" != "www-data" ]
then
  echo "WARNING: Unexpected value LANDO_WEBROOT_GROUP=${LANDO_WEBROOT_GROUP}."
fi

# The file must be writable by group and the group to be www-data:
right_perms=$(find "${SSH_AUTH_SOCK}" -perm -g+w -group www-data | wc -l)
if [ $right_perms -eq 0 ]
then
  echo "Wrong permissions on ${SSH_AUTH_SOCK}:"
  ls -l "${SSH_AUTH_SOCK}"
  exit 101
fi
exit 0
