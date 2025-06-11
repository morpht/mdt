#!/usr/bin/env bash

set -ev
set -o pipefail

test -n "${GIT_REMOTE}"
test -n "${GIT_DEFAULT_BRANCH}"
test -n "${GIT_BRANCH_DELETE}"
test -n "${GIT_NAME}"
test -n "${GIT_EMAIL}"
test -n "${SSH_DEPLOYMENT_KEY}"

# Set up private ssh key for git
mkdir ~/.ssh
chmod 700 ~/.ssh
echo "${SSH_DEPLOYMENT_KEY}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

git config --global core.sshCommand "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# create a temporary directory and cd into it:
mkdir hosting-repo
cd hosting-repo

git config --global init.defaultBranch "${GIT_DEFAULT_BRANCH}"
git init
git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"

git remote add hosting "$GIT_REMOTE"

if git ls-remote hosting 'refs/heads/*' | grep -q "refs/heads/${GIT_BRANCH_DELETE}$"
then
  echo "Deleting branch ${GIT_BRANCH_DELETE} in the hosting repository:"
  git push hosting --delete "${GIT_BRANCH_DELETE}"
else
  echo "There is no branch ${GIT_BRANCH_DELETE} in the hosting repository. No change has been made."
fi

set +v
