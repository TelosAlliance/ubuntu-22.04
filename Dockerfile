# syntax=docker/dockerfile:1.3-labs
# vim:syntax=dockerfile
FROM ubuntu:jammy-20220801

# Set this before `apt-get` so that it can be done non-interactively
ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/New_York
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# Golang env
ENV GOROOT /opt/go
ENV GOPATH $HOME/work/

# Rust env
ENV RUST_HOME /opt/rust
ENV CARGO_HOME $RUST_HOME
ENV RUSTUP_HOME $RUST_HOME/.rustup

# NodeJS env
ENV NODE_VERSION v16.13.0
ENV NODE_BUILD node-$NODE_VERSION-linux-x64
ENV NODE_BIN /opt/node-$NODE_VERSION-linux-x64/bin

# Set PATH to include custom bin directories
ENV PATH $GOPATH/bin:$GOROOT/bin:$RUST_HOME/bin:$NODE_BIN:$PATH

# KEEP PACKAGES SORTED ALPHABETICALY
# Do everything in one RUN command
RUN /bin/bash <<EOF
set -euxo pipefail
apt-get update
# Install packages needed to set up third-party repositories
apt-get install -y --no-install-recommends \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  gnupg \
  python3 \
  python3-pip \
  software-properties-common \
  wget
# Install AWS cli
pip3 install awscli
# Use kitware's CMake repository for up-to-date version
curl -sSf https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
apt-add-repository 'deb https://apt.kitware.com/ubuntu/ jammy main'
apt-get install -y --no-install-recommends \
  cmake
# Use NodeSource's NodeJS 18.x repository
curl -sSf https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y --no-install-recommends \
  nodejs
# Install nvm binary
curl -sSf https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# Install other javascript package managers
npm install -g yarn pnpm
# Install newer version of Go than is included with Ubuntu
curl -sSf https://dl.google.com/go/go1.19.linux-amd64.tar.gz | tar -xz -C /opt
# Install Rust prereqs
apt-get install -y --no-install-recommends \
  musl-tools
# Install Rust and Rust tools
curl -sSf https://sh.rustup.rs | sh -s -- -y
curl -sSf https://just.systems/install.sh | bash -s -- --to "$RUST_HOME/bin"
cargo install cargo-about
cargo install cargo-bundle-licenses
cargo install cargo-deny
cargo install cargo-license
cargo install cargo-lichking
rustup target add x86_64-unknown-linux-musl
rustup target add armv7-unknown-linux-gnueabihf
rm -rf "$RUST_HOME/registry" "$RUST_HOME/git"
chmod 777 "$RUST_HOME"
# Install gstreamer
apt-get install -y --no-install-recommends \
  gstreamer1.0-nice \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-tools \
  libgstreamer1.0-dev \
  libglib2.0-dev \
  libgstreamer-plugins-bad1.0-dev \
  libjson-glib-dev \
  libsoup2.4-dev
# add Ansible repository
add-apt-repository --yes --update ppa:ansible/ansible
# Install everything else
apt-get install -y --no-install-recommends \
  ansible \
  autoconf \
  automake \
  bc \
  cpio \
  cppcheck \
  device-tree-compiler \
  elfutils \
  file \
  gawk \
  gdb \
  gettext \
  git \
  gosu \
  jq \
  kmod \
  libasound2-dev \
  libavahi-compat-libdnssd-dev \
  libboost-all-dev \
  libcurl4-openssl-dev \
  libncurses5-dev \
  libpcap-dev \
  libsndfile1-dev \
  libssl-dev \
  libtool \
  libwebsocketpp-dev \
  libwebsockets-dev \
  locales-all \
  lzop \
  ncurses-dev \
  openssh-client \
  pandoc \
  rsync \
  shellcheck \
  software-properties-common \
  swig \
  time \
  unzip \
  uuid-dev \
  valgrind \
  vim \
  zip \
  zlib1g-dev
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

COPY patch /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
