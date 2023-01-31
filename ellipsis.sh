#!/usr/bin/env bash

# Main list of packages for desktop. OS-agnostic.
packages=(
    thomshouse-ellipsis/zsh
);

# List of apt packages to install on any apt-based system
apt_packages=(
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
    # Add ellipsis bin to $PATH if it isn't there
    if [ ! "$(command -v ellipsis)" ]; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi

    # Install packages
    meta.install_packages

    # Run setup scripts
    for file in $(find "$PKG_PATH/setup" -maxdepth 1 -type f -name "*.sh"); do
        [ -e "$file" ] || continue
        PKG_PATH=$PKG_PATH bash "$file"
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

    # Run init scripts
    for file in $(find "$PKG_PATH/init" -maxdepth 1 -type f -name "*.zsh"); do
        [ -e "$file" ] || continue
        . "$file"
    done
}

pkg.link() {
    fs.link_files links;
}