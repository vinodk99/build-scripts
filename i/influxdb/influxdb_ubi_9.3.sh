# Variables
PACKAGE_NAME=influxdb
PACKAGE_VERSION=${1:-v2.7.6}
PACKAGE_URL=https://github.com/influxdata/influxdb

# Install dependencies
yum install -y gcc gcc-c++ python3 python3-devel git wget sudo make autoconf automake \
               zlib-devel bzip2 bzip2-devel xz-devel curl-devel openssl-devel \
               ncurses-devel diffutils libtool json-c.ppc64le elfutils-libelf.ppc64le cmake patch libcap

# Install Protocol Buffers
git clone https://github.com/protocolbuffers/protobuf
cd protobuf
git checkout v3.17.3
./autogen.sh
./configure
make
make install
cd ..

# Set PKG_CONFIG_PATH for protobuf
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# Install Protobuf-C
git clone https://github.com/protobuf-c/protobuf-c
cd protobuf-c
git checkout v1.4.0
./autogen.sh
./configure
make
make install
cd ..

# Install Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustc --version

# Install Go
GO_VERSION=1.21.6
wget https://golang.org/dl/go$GO_VERSION.linux-ppc64le.tar.gz
tar -C /usr/local -xzf go$GO_VERSION.linux-ppc64le.tar.gz
rm -rf go$GO_VERSION.linux-ppc64le.tar.gz
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Install Flux
git clone https://github.com/influxdata/flux
cd flux
make
make install
cd ..

# Find the directory containing `flux.pc`
FLUX_PC_PATH=$(find /usr/local -name flux.pc | xargs dirname)

# Update PKG_CONFIG_PATH for flux
export PKG_CONFIG_PATH=$FLUX_PC_PATH:$PKG_CONFIG_PATH

# Clone InfluxDB repository and checkout the specified version
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

# Build InfluxDB
if ! go build ./...; then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

# Test InfluxDB build
if ! go test -race ./...; then
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
