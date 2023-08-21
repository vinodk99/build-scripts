#!/bin/bash -e
# ----------------------------------------------------------------------------
# Package          : grafana
# Version          : v10.0.3
# Source repo      : https://github.com/grafana/grafana.git
# Tested on        : UBI 8.7
# Language         : Go,Typescript
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

PACKAGE_NAME="grafana"
PACKAGE_URL="https://github.com/grafana/grafana.git"
PACKAGE_VERSION=
export NODE_VERSION=${NODE_VERSION:-18}
GO_VERSION=1.20.5

#install nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install $NODE_VERSION
npm install -g yarn

#install go
wget https://golang.org/dl/go$GO_VERSION.linux-ppc64le.tar.gz && \
tar -C /usr/local -xzf go$GO_VERSION.linux-ppc64le.tar.gz && \
rm -rf go$GO_VERSION.linux-ppc64le.tar.gz
export GOROOT=/usr/local/go && \
export GOPATH=$HOME && \
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout v10.0.3

#Build frontend
yarn install
mkdir plugins-bundled/external
export NODE_OPTIONS="--max-old-space-size=8192"
make build-js

#Build backend
make gen-go
make deps-go
make build-go

#Test backend
make test-go
