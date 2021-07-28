#!/usr/bin/env bash

# Main list of packages for desktop. OS-agnostic.
packages=(
    thomshouse-ellipsis/zsh
);

# Set of prerequisites to support WSL functionality
wsl_prereqs=(
    thomshouse-ellipsis/wsl-utils
    thomshouse-ellipsis/chocolatey
);

# Load the metapackage functions
. "$PKG_PATH/src/meta.bash"

pkg.install() {
    meta.install_packages
    meta.check_init_autoload
}

pkg.init() {
    # Add ellipsis bin to $PATH if it isn't there
    if ! utils.cmd_exists ellipsis; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi
}