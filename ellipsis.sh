#!/usr/bin/env bash

# Main list of packages for desktop. OS-agnostic.
packages=(
    thomshouse/zsh
    thomshouse-ellipsis/docker
);

# List of apt packages to install on any apt-based system
apt_packages=(
    keychain
    zip
    unzip
);

# List of homebrew formulae to install on MacOS-based systems
brew_packages=(
);
cask_packages=(
);

# List of choco packages to install on Windows systems
choco_packages=(
);

# Set of platform-specific prerequisites to support each platform
linux_prereqs=()
macos_prereqs=()
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

    # Initialize keychain if it's installed
    if [[ "$(command -v keychain)" ]]; then
        eval `keychain --eval --agents ssh id_rsa`
    fi
}
