#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : geospatial
# Version          : 2.15.0.0
# Source repo      : https://github.com/opensearch-project/geospatial
# Tested on        : UBI:9.3
# Language         : Java
# Travis-Check     : True
# Script License   : Apache License, Version 2 or later
# Maintainer       : Vinod K<Vinod.K1@ibm.com>
#
# Disclaimer       : This script has been tested in non-root mode on given
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
# ---------------------------------------------------------------------------

sudo yum install -y  git gcc patch make java-17-openjdk-devel python3 python3-devel bzip2-devel zlib-devel openssl-devel

PACKAGE_NAME=geospatial
PACKAGE_URL=https://github.com/opensearch-project/geospatial
PACKAGE_VERSION=${1:-2.15.0.0}

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION
if ! ./gradlew build -x test -x :yamlRestTest -x :integTest ; then
        echo "------------------$PACKAGE_NAME:Build_fails---------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
        exit 1
elif ! ./gradlew test integTest  -Dtests.heap.size=4096m ; then
        echo "------------------$PACKAGE_NAME:Build_and _test_fails---------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
        exit 2
else
        echo "Build and Test Success"
        exit 0
fi
