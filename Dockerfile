FROM ubuntu:18.04

MAINTAINER Diego Nehab <diego.nehab@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive

ENV BASE /opt/riscv

# Install basic development tools
# ----------------------------------------------------
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        unzip ca-certificates \
        bison flex\
        build-essential autoconf automake libtool autotools-dev \
        git make pkg-config vim libboost-dev libreadline-dev socat wget && \
    mkdir -p $BASE && \
    rm -rf /var/lib/apt/lists/*

# Install libfdt
# ----------------------------------------------------
RUN \
    NPROC=$(nproc) && \
    cd $BASE && \
    git clone https://github.com/cartesi/dtc.git && \
    cd dtc && \
    git checkout cartesi && \
    make -j$NPROC NO_PYTHON=1 PREFIX=/usr/local install && \
    cd $BASE && \
    \rm -rf $BASE/dtc


# Install cryptopp
# ----------------------------------------------------
RUN \
    NPROC=$(nproc) && \
    cd $BASE && \
    git clone https://github.com/cartesi/cryptopp.git && \
    cd cryptopp && \
    git checkout cartesi && \
    make -j$NPROC && \
    make install && \
    cd $BASE && \
    \rm -rf $BASE/cryptopp

# Install grpc
# ----------------------------------------------------
RUN \
    NPROC=$(nproc) && \
    cd $BASE && \
    git clone --branch v1.16.0 --depth 1 https://github.com/grpc/grpc.git && \
    cd $BASE/grpc && \
    git checkout v1.16.0 && \
    git submodule update --init && \
    make -j$NPROC install && \
    cd $BASE/grpc/third_party/protobuf && \
    make install && \
    mv $BASE/grpc/examples /usr/local/share/grpc && \
    cd $BASE && \
    \rm -rf $BASE/grpc

# Install Lua 5.3.5 compiled for C++
# ----------------------------------------------------
COPY luapp.patch $BASE
COPY luapp53.pc /usr/local/lib/pkgconfig

RUN \
    NPROC=$(nproc) && \
    cd $BASE && \
    wget https://www.lua.org/ftp/lua-5.3.5.tar.gz && \
    tar -zxvf lua-5.3.5.tar.gz && \
    cd $BASE/lua-5.3.5 && \
    patch -p1 < ../luapp.patch && \
    make -j$NPROC linux && \
    make install && \
    cd $BASE && \
    ln -s /usr/local/bin/luapp5.3 /usr/local/bin/luapp && \
    \rm -rf $BASE/lua-5.3.5

USER root
WORKDIR ~
