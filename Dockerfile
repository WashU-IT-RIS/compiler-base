FROM ubuntu:22.04

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    bison \
    chrpath \
    debhelper \
    dpatch \
    ethtool \
    flex \
    gfortran \
    git \
    graphviz \
    iproute2 \
    kmod \
    libelf-dev \
    libfind-lib-perl \
    libfuse2 \
    libglib2.0-0 \
    libltdl-dev \
    libmnl0 \
    libnl-3-dev \
    libnl-route-3-dev \
    libnuma-dev \
    libssl-dev \
    libusb-1.0-0-dev \
    lsb-release \
    lsof \
    m4 \
    net-tools \
    pciutils \
    pkg-config \
    python3 \
    swig \
    tk-dev \
    tzdata \
    udev \
    wget && \
    apt-get clean all

# Set MOFED version, OS version and platform
ENV MOFED_VERSION=5.8-6.0.4.2
ENV OS_VERSION=ubuntu22.04
ENV PLATFORM=x86_64

RUN mkdir /tmp/mofed && \
    cd /tmp/mofed && \
    wget -q http://content.mellanox.com/ofed/MLNX_OFED-${MOFED_VERSION}/MLNX_OFED_LINUX-${MOFED_VERSION}-${OS_VERSION}-${PLATFORM}.tgz && \
    tar -xvf MLNX_OFED_LINUX-${MOFED_VERSION}-${OS_VERSION}-${PLATFORM}.tgz && \
    MLNX_OFED_LINUX-${MOFED_VERSION}-${OS_VERSION}-${PLATFORM}/mlnxofedinstall \
      --user-space-only \
      --without-fw-update  \
      -q && \
    rm -rf /tmp/mofed

#COPY oneapi /opt/intel/oneapi 
# Install Intel OneAPI
ENV ONEAPI_VERSION=2023.2-devel
RUN apt-get update -y && \
    apt-get install -y gpg-agent wget \
    wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list && \
    apt-get update -y && \
    apt-get install -y intel-oneapi-hpc-toolkit-${ONEAPI_VERSION}

