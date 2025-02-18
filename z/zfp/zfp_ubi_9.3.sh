#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package       : zfp
# Version       : 1.0.0
# Source repo   : https://github.com/LLNL/zfp
# Tested on     : UBI:9.3
# Language      : C,Python
# Travis-Check  : True
# Script License: Apache License 2.0
# Maintainer    : Vinod K<Vinod.K1@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

#!/bin/bash

PACKAGE_NAME=zfp
PACKAGE_VERSION=${1:-1.0.0}
PACKAGE_URL=https://github.com/LLNL/zfp
PACKAGE_DIR="./zfp"

echo "Installing dependencies..."
yum install -y epel-release
yum install -y wget gcc gcc-c++ gcc-gfortran git make \
               python python-devel python3-pip \
               openssl-devel cmake

echo "Cloning and installing..."
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

echo "Installing Python dependencies..."
pip install --upgrade pip
pip install cython==0.29.36 numpy==1.23.5 wheel

echo "Creating build directory..."
mkdir -p build
cd build

echo "Running CMake..."
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_ZFPY=ON \
    -DPYTHON_EXECUTABLE=$(which python3) \
    -DPYTHON_INCLUDE_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('include'))") \
    -DPYTHON_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")

echo "Building zfp..."
make -j$(nproc)

echo "Setting up library paths..."
export LD_LIBRARY_PATH=$(pwd)/lib64:$LD_LIBRARY_PATH
ldconfig

echo "Installing Python package..."
if ! pip install .. ; then
    echo "------------------$PACKAGE_NAME: Install Failed -------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Install Failed"
    exit 1
else
    echo "------------------$PACKAGE_NAME: Install Success ------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Pass | Install Success"
    exit 0
fi

# Skipping test part as no Python tests are available.
