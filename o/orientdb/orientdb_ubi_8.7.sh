#!/bin/bash -e
# ----------------------------------------------------------------------------
#
# Package       : orientdb
# Version       : 3.2.27
# Source repo   : https://github.com/orientechnologies/orientdb.git
# Tested on     : UBI: 8.7
# Language      : Java
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Vinod K <Vinod.K1@ibm.com>
#
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=orientdb
PACKAGE_VERSION=${1:-3.2.27}
PACKAGE_URL=https://github.com/orientechnologies/orientdb.git

yum install -y git wget tar openssl-devel freetype fontconfig
HOME_DIR=${PWD}
cd $HOME_DIR

#install java
wget https://github.com/ibmruntimes/semeru21-binaries/releases/download/jdk-21%2B35_openj9-0.42.0-m0/ibm-semeru-open-jdk_ppc64le_linux_21_35_openj9-0.42.0-m0.tar.gz
tar -zxf ibm-semeru-open-jdk_ppc64le_linux_21_35_openj9-0.42.0-m0.tar.gz
export JAVA_HOME=$HOME_DIR/jdk-21+35
export PATH=$JAVA_HOME/bin:$PATH
java -version

#install maven
wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
tar -zxf apache-maven-3.9.6-bin.tar.gz
cp -R apache-maven-3.9.6 /usr/local
ln -s /usr/local/apache-maven-3.9.6/bin/mvn /usr/bin/mvn

cd $HOME_DIR
git clone $PACKAGE_URL
cd $PACKAGE_NAME/
git checkout $PACKAGE_VERSION

if ! mvn -B package --file pom.xml ; then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi

