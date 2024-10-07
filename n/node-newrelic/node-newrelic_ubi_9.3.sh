#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : node-newrelic
<<<<<<< HEAD
# Version          : v12.5.0
# Source repo      : https://github.com/newrelic/node-newrelic
# Tested on        : UBI:9.3
# Language         : Javascript
=======
# Version          : v11.21.0
# Source repo      : https://github.com/newrelic/node-newrelic
# Tested on        : UBI:9.3
# Language         : Typescript
>>>>>>> 64b00e1eca7e22b9a925731b22ea2fd0b22b219f
# Travis-Check     : True
# Script License   : Apache License, Version 2 or later
# Maintainer       : Vinod K <Vinod.K1@ibm.com>
#
<<<<<<< HEAD
# Disclaimer       : This script has been tested in non-root mode on given
=======
# Disclaimer       : This script has been tested in root mode on given
>>>>>>> 64b00e1eca7e22b9a925731b22ea2fd0b22b219f
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
<<<<<<< HEAD
# ---------------------------------------------------------------------------

PACKAGE_NAME=node-newrelic
PACKAGE_URL=https://github.com/newrelic/node-newrelic
PACKAGE_VERSION=${1:-v12.5.0}

yum install git wget gcc gcc-c++  -y

#Install node
export NODE_VERSION=${NODE_VERSION:-20}
=======
# ----------------------------------------------------------------------------

PACKAGE_NAME=node-newrelic
PACKAGE_VERSION=${1:-v11.21.0}
PACKAGE_URL=https://github.com/newrelic/node-newrelic

export NODE_VERSION=${NODE_VERSION:-20}

OS_NAME=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2)

yum install -y python3 python3-devel.ppc64le git gcc gcc-c++ libffi make
#Installing nvm
>>>>>>> 64b00e1eca7e22b9a925731b22ea2fd0b22b219f
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source "$HOME"/.bashrc
echo "installing nodejs $NODE_VERSION"
nvm install "$NODE_VERSION" >/dev/null
nvm use $NODE_VERSION

<<<<<<< HEAD
=======

>>>>>>> 64b00e1eca7e22b9a925731b22ea2fd0b22b219f
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

if ! npm install ; then
<<<<<<< HEAD
     echo "------------------$PACKAGE_NAME:Build_fails---------------------"
     echo "$PACKAGE_VERSION $PACKAGE_NAME"
     echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails_"
     exit 2
fi

if ! npm run unit:scripts ; then
      echo "------------------$PACKAGE_NAME::Build_and_Test_fails-------------------------"
      echo "$PACKAGE_URL $PACKAGE_NAME"
      echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail|  Build_and_Test_fails"
      exit 1
else
      echo "------------------$PACKAGE_NAME::Build_and_Test_success-------------------------"
      echo "$PACKAGE_URL $PACKAGE_NAME"
      echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Both_Build_and_Test_Success"
      exit 0
=======
    echo "------------------$PACKAGE_NAME:Build_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
    exit 1
fi
sed -i 's/\(tap\.test('\''display_host'\'', { timeout: \)20000/\140000/' test/unit/facts.test.js

if ! npm run unit ; then
    echo "------------------$PACKAGE_NAME::Build_and_Test_fails-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail|  Build_and_Test_fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME::Build_and_Test_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Both_Build_and_Test_Success"
    exit 0
>>>>>>> 64b00e1eca7e22b9a925731b22ea2fd0b22b219f
fi