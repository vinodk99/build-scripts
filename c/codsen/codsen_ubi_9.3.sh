#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : codsen
# Version          : util-nonempty@5.0.16
# Source repo      : https://github.com/codsen/codsen
# Tested on        : UBI:9.3
# Language         : Javascript
# Travis-Check     : True
# Script License   : Apache License, Version 2 or later
# Maintainer       : vinodk99 <Vinod.K1@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# -----------------------------------------------------------------------------

PACKAGE_NAME=codsen
PACKAGE_VERSION=${1:-util-nonempty@5.0.16}
PACKAGE_URL=https://github.com/codsen/codsen

yum install -y wget git libcurl-devel make gcc-c++ patch python3 python3-devel

export NODE_VERSION=${NODE_VERSION:-20}
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source "$HOME"/.bashrc
echo "Installing Node.js $NODE_VERSION"
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"

git clone "$PACKAGE_URL"
cd "$PACKAGE_NAME"
git checkout "$PACKAGE_VERSION"

if ! npm install; then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

cd node_modules/codsen-utils/
npm install
npm run build
cd ../..

cd node_modules/lerna-clean-changelogs
npm install
npm run build
cd ../..

if ! npm test; then
    echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi