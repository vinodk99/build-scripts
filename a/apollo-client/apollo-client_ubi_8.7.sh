#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : apollo-client
# Version          : v3.8.4
# Source repo      : https://github.com/apollographql/apollo-client
# Tested on        : UBI 8.7
# Language         : Typescript
# Travis-Check     : True
# Script License   : Apache License, Version 2 or later
# Maintainer       : Vinod K <Vinod.K1@ibm.com>
#
# Disclaimer       : This script has been tested in root mode on given
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=apollo-client
PACKAGE_VERSION=${1:-v3.8.4}
PACKAGE_URL=https://github.com/apollographql/apollo-client

HOME_DIR=${PWD}

OS_NAME=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2)

yum install -y git make gcc gcc-c++ python38-devel

#install nodejs
NODE_VERSION=v20.7.0
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
source ~/.bashrc
nvm install $NODE_VERSION

cd $HOME_DIR
git clone $PACKAGE_URL
cd $PACKAGE_NAME/
git checkout $PACKAGE_VERSION

if ! npm ci ; then
       echo "------------------$PACKAGE_NAME:Install_fails---------------------"
       echo "$PACKAGE_VERSION $PACKAGE_NAME"
       echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_Fails"
       exit 1
fi
sed -i '3602 i\    jest.useFakeTimers();' src/react/hooks/__tests__/useSuspenseQuery.test.tsx
sed -i '3605 i\    jest.useRealTimers();' src/react/hooks/__tests__/useSuspenseQuery.test.tsx
if ! npm run test:ci ; then
      echo "------------------$PACKAGE_NAME::Build_and_Test_fails-------------------------"
      echo "$PACKAGE_URL $PACKAGE_NAME"
      echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Both_Install_and_Test_Fails"
      exit 2
else
      echo "------------------$PACKAGE_NAME::Build_and_Test_success-------------------------"
      echo "$PACKAGE_URL $PACKAGE_NAME"
      echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Both_Install_and_Test_Success"
      exit 0
fi
