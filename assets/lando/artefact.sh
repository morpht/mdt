#!/usr/bin/env bash

echo "###"
echo "###"
echo "###"
echo "### Check out https://github.com/morpht/convivial/actions The build should be automated by now."
echo "###"
echo "###"
echo "###"

# Comment out following line to run the build manually in case of problems with Github actions.
exit 0

set -e

### trap temporarily commented out to see whether
### we will get more info about possible errors:
#
# trap 'catch $? $LINENO' EXIT

catch() {
  if [ "$1" != "0" ]; then
    # error handling goes here
    echo "Error $1 occurred on $2"
  fi
}

### Verify ssh auth socket has good perms on MacOS:
ssh_socket_problem=0
/app/.lando/verify_mac_ssh_socket.sh || ssh_socket_problem=$?
if [ $ssh_socket_problem -ne 0 ]; then
  echo "Please fix ssh auth socket by running 'lando ssh-fix'. Exiting."
  exit $ssh_socket_problem
fi

### Verify our local branch is not behind remote:
branch_behind=0
git remote update ; git status -uno | grep -q 'branch is behind' && branch_behind=1
if [ $branch_behind -eq 1 ]; then
  echo "ERROR: Your local branch is behind the remote branch, update it first. Cannot continue."
  exit 2
fi

### Verify out local branch has been pushed to remote:
current_branch=$(git symbolic-ref --short -q HEAD)
if [ "$current_branch" == "" ]; then
  echo "ERROR: Cannot detect current branch. Cannot continue."
  exit 3
fi
not_pushed=$(git log "${current_branch}" --not --remotes --oneline)
if [ "${not_pushed}" != "" ]; then
  echo "ERROR: Your local branch ${current_branch} hasn't been pushed. Cannot continue."
  exit 4
fi


runtime=$(date +"%Y-%m-%d-%H-%M-%S")
projectfolder="/app"
deployfolder="/tmp/deploy"
tmp_artefact_repo="/tmp/tmp_artefact_$runtime"
project_name=$(grep 'name:.*' .lando.yml|cut -f2- -d:|xargs)
hash=$(drush site:alias --fields=host "@pantheon.$project_name.dev"|grep host|cut -f2- -d:|xargs|cut -f3 -d.)
if [ -z "$hash" ]
then
  echo "Drush aliases are not set up. Exiting."
  exit 0
fi
# @ToDo: Separate out remote. Similar as list of multisites.
artefactrepo="ssh://codeserver.dev.$hash@codeserver.dev.$hash.drush.in:2222/~/repository.git"

# Figure out who is building.
gitname=$(git config user.name || true)
gitemail=$(git config user.email || true)
# and what:
shalite=$(git rev-parse --short HEAD)

if [ "$gitname" == "" ]; then
  gitname="Morpht Automation"
  gitemail="contact@morpht.com"
fi

echo "# Starting fresh artefact build in ${deployfolder}"

rm -rf $deployfolder
mkdir -p $deployfolder

echo "# Cloning current state of local repo to $deployfolder. This means:"
echo "  * Currently checked out branch or commit will be used."
echo "  * Uncommitted changes outside of deploy folder are ignored. Only committed changes are deployed."
echo "  * Global gitignore files are ignored."
cd $projectfolder
git clone $projectfolder $deployfolder
cd $deployfolder
# Get current branch name.
branchname="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"
if [ "$branchname" == "HEAD" ]; then
  # We are not on a branch, get short commit hash instead.
  branchname="$(git rev-parse --short HEAD)"
fi
echo "# Resolved branch for a build: $branchname."

echo "# Fetching all contrib code."
composer install
# @ToDo: Front-end tasks.

# Get artefact repo.
mkdir -p "${tmp_artefact_repo}"
cd "${tmp_artefact_repo}"
git clone "${artefactrepo}" .
git checkout "${branchname}" || git checkout -b "${branchname}"

# Swithch out git repos.
cd $deployfolder
rm -f .gitignore
rm -rf .git
for f in $(find ./* -type d -name .git)
do
  rm -rf $f
done

mv "${tmp_artefact_repo}/.git" .
rm -rf "${tmp_artefact_repo}"

# Remove gitignore from downloaded libraries
for f in $(find ./web/libraries/* -type f -name .gitignore)
do
  rm $f
done

# Commit new artefact.
git config --local core.excludesfile false
git config --local core.fileMode true
git config --local user.name "${gitname}"
git config --local user.email "${gitemail}"
git add -A .
git commit -m "Lando build of ${branchname} @ ${shalite} at ${runtime}." --no-gpg-sign

# Deploy if that was explicitly requested
if [ "$1" == "deploy" ]; then
  git push origin "${branchname}"
  shafat=$(git rev-parse --short HEAD)
  # Mark deploy in lite repo.
  cd $projectfolder
  git tag "${runtime}-${shafat}"
  git push --tags
  exit 0
fi

# Confirm push to remote.
read -p "Artefact build is done. Ready to push to remote? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  git push origin "${branchname}"
  shafat=$(git rev-parse --short HEAD)
  # Mark deploy in lite repo.
  cd $projectfolder
  git tag "${runtime}-${shafat}"
  git push --tags
fi
exit 0
