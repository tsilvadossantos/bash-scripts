#!/bin/bash
clear

ENV="/opt"
UI_REPO="API-desktop"
UI_REPO_LOC="${ENV}/${UI_REPO}"
NVM_DIR="$HOME/.nvm"


if [ $# -eq 0 ]; then
    echo "Release not informed!!! (ERROR -1)"
    exit 1
fi

# Pull source for branch
sudo rm -rf $UI_REPO_LOC

#git clone
cd $ENV
echo "Cloning platform repo"
sudo su -c "git clone <repo>:<user>/${UI_REPO}"

sleep 5

cd $UI_REPO_LOC

#git rebase
echo "Rebasing for origin/$1"
sudo su -c "git rebase origin/$1"

echo "Checking out branch $1"
sudo su -c "git checkout -f $1"

echo "Pulling latest code"
sudo su -c "git pull -f"

#set up nvm https://github.com/creationix/nvm
rm -rf $NVM_DIR
(
  git clone https://github.com/creationix/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && . "$NVM_DIR/nvm.sh"

export $NVM_DIR
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Build Node - Check for nvm releases https://github.com/creationix/nvm/releases
cd $UI_REPO_LOC
nvm install node
sudo su -c "npm install"

# Start development server for local development:
sudo su -c "npm start"

# Generate a production build which can be manually deployed somewhere:
sudo su -c "npm run package:datacenter"
