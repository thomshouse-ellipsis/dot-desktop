#!/usr/bin/env bash

# List of apt packages to install on any apt-based system
apt_packages=(
    keychain
    zip
    unzip
);

# Main list of packages for desktop. OS-agnostic.
packages=(
    thomshouse/zsh
    thomshouse-ellipsis/docker
);

# Set of prerequisites to support WSL functionality
wsl_prereqs=(
    thomshouse-ellipsis/wsl-utils
    thomshouse-ellipsis/chocolatey
);

# Load the metapackage functions
test -n "$PKG_PATH" && . "$PKG_PATH/src/meta.bash"

pkg.install() {
    meta.install_packages
    meta.check_init_autoload
    pkg.init
}

pkg.init() {
    # Add ellipsis bin to $PATH if it isn't there
    if [ ! "$(command -v ellipsis)" ]; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi
}
