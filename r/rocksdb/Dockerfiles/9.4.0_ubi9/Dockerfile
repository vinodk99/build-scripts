FROM registry.access.redhat.com/ubi9/ubi:9.3

ARG PACKAGE_VERSION=v9.4.0

RUN curl -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf install -y epel-release-latest-9.noarch.rpm && \
    yum install -y git gcc-c++ gcc wget make  python3 yum-utils apr-devel perl openssl-devel automake autoconf libtool cmake gflags  gflags-devel

RUN git clone --recurse-submodules https://github.com/facebook/rocksdb && \
    cd rocksdb && \
    git checkout $PACKAGE_VERSION && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build .

<<<<<<< HEAD
CMD ["/bin/bash"]
=======
CMD ["/bin/bash"]
>>>>>>> 38858f052c49a657ab098dd85ce3f46d10afc1e6
