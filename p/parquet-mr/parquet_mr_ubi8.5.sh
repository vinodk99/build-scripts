#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package	: parquet-mr
# Version	: apache-parquet-1.12.3
# Source repo	: https://github.com/apache/parquet-mr
# Tested on	: UBI 8.5
# Language      : Java
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer	: Vinod K <Vinod.K1@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=parquet-mr
PACKAGE_VERSION=apache-parquet-1.12.3
PACKAGE_URL=https://github.com/apache/parquet-mr.git

#Install required dependencies
yum install -y git make wget gcc-c++ patch java-11-openjdk java-11-openjdk-devel java-11-openjdk-headless 

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$PATH:$JAVA_HOME/bin

#install maven
wget https://archive.apache.org/dist/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz
tar -zxf apache-maven-3.8.7-bin.tar.gz
cp -R apache-maven-3.8.7 /usr/local
ln -s /usr/local/apache-maven-3.8.7/bin/mvn /usr/bin/mvn

#install protobuf compiler
wget https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz 
tar xvzf protobuf-2.6.1.tar.gz --no-same-owner
rm -f protobuf-2.6.1.tar.gz
cd protobuf-2.6.1/
./configure
make
make install

#install thrift
wget -nv http://archive.apache.org/dist/thrift/0.13.0/thrift-0.13.0.tar.gz
tar xzf thrift-0.13.0.tar.gz --no-same-owner
cd thrift-0.13.0
chmod +x ./configure
./configure --disable-libs
make install

git clone https://github.com/apache/parquet-format.git
cd parquet-format
mvn package
mvn test

wget -nv http://archive.apache.org/dist/thrift/0.16.0/thrift-0.16.0.tar.gz
tar xzf thrift-0.16.0.tar.gz --no-same-owner
cd thrift-0.16.0
chmod +x ./configure
./configure --disable-libs
make install

#Clone the top-level repository
cd $WORKDIR
wget https://raw.githubusercontent.com/vinodk99/build-scripts/parquet-mr1/p/parquet-mr/parquet_mr.patch
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION
git apply ../parquet_mr.patch;

#Build and test

if ! mvn package; then
    echo "------------------$PACKAGE_NAME:Build_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
    exit 1
fi

 if ! mvn test; then
    echo "------------------$PACKAGE_NAME::Build_and_Test_fails-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Fail|  Build_and_Test_fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME::Build_and_Test_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Both_Build_and_Test_Success"
    exit 0
fi

