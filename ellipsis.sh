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
    keychain
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
    # Add ellipsis bin to $PATH if it isn't there
    if [ ! "$(command -v ellipsis)" ]; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi

    # Install packages
    meta.install_packages

    # Run setup scripts
    for file in $PKG_PATH/setup/*[.]sh; do
        PKG_PATH=$PKG_PATH sh "$file"
    done

    # Run full initialization
    meta.check_init_autoload
    pkg.init
}

pkg.init() {
    # Add ellipsis bin to $PATH if it isn't there
    if [ ! "$(command -v ellipsis)" ]; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi

    # Add package bin to $PATH
    export PATH=$PKG_PATH/bin:$PATH

    # Initialize keychain if it's installed
    if [[ "$(command -v keychain)" ]]; then
        eval `keychain -q --eval --agents ssh id_rsa`
    fi

    # Run init scripts
    for file in $PKG_PATH/init/*[.]zsh; do
        . "$file"
    done
}

pkg.link() {
    fs.link_files links;

    # Create default gitignore
    if [[ ! -f "$HOME/.gitignore" ]]; then
        cp $PKG_PATH/src/gitconfig.example $HOME/.gitignore
    fi
}