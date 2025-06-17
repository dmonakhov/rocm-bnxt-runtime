ARG BASE_IMAGE=rocm/pytorch:rocm6.4_ubuntu22.04_py3.10_pytorch_release_2.6.0

FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG BNXT_VERSION=232.0.164.5
ARG BLD=/tmp/bld
# Install RoCE libs deps
RUN apt-get update -y \
    && apt-get install -y \
      gcc \
      git \
      make \
      libtool \
      autoconf \
      librdmacm-dev \
      libibumad-dev \
      rdmacm-utils \
      infiniband-diags \
      ibverbs-utils \
      ethtool \
      libibverbs-dev \
      rdma-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install libbnxt_re
COPY bnxt_rocelib/libbnxt_re-${BNXT_VERSION}.tar.gz /tmp/
RUN mkdir -p $BLD \
    && cd $BLD \
    && tar -xf /tmp/libbnxt_re-${BNXT_VERSION}.tar.gz \
    && cd libbnxt_re-${BNXT_VERSION} \
    && sh autogen.sh \
    && ./configure \
    && make -j \
    && find /usr/lib64/ /usr/lib -name "libbnxt_re-rdmav*.so" -exec mv {} {}.inbox \; \
    && make install all \
    && sh -c "echo /usr/local/lib >> /etc/ld.so.conf" \
    && ldconfig \
    && cp -f bnxt_re.driver /etc/libibverbs.d/ \
    && find . -name "*.so" -exec md5sum {} \; \
    && cd / \
    rm -rf $BLD

ENV BNXT_VERSION=$BNXT_VERSION