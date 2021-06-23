FROM ubuntu:bionic as base

# Install dependencies
# We need uhd so enb and ue are built
# Use curl and unzip to get a specific commit state from github
# Also install ping to test connections
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     cmake \
     libuhd-dev \
     uhd-host \
     libboost-program-options-dev \
     libvolk1-dev \
     libfftw3-dev \
     libmbedtls-dev \
     libsctp-dev \
     libconfig++-dev \
     curl \
     iputils-ping \
     iproute2 \
     iptables \
     unzip \
     libzmq3-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /srsran

# Pinned git commit used for this example
ARG COMMIT=master

# Download and build
RUN curl -LO https://github.com/jwijenbergh/srsRAN/archive/${COMMIT}.zip \
 && unzip ${COMMIT}.zip \
 && rm ${COMMIT}.zip

WORKDIR /srsran/srsRAN-build

# build
RUN cmake ../srsRAN-${COMMIT} \
 && make \
 && make test

# install
RUN make install

# Update dynamic linker
RUN ldconfig

WORKDIR /srsran

# Copy all .example files and remove that suffix
RUN cp srsRAN-${COMMIT}/*/*.example ./ \
 && bash -c 'for file in *.example; do mv "$file" "${file%.example}"; done'

# Run commands with line buffered standard output
# (-> get log messages in real time)
ENTRYPOINT [ "stdbuf", "-o", "L" ]
