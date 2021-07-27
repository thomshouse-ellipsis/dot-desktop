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

pkg.install() {
    # Determine which set of packages we'll install based on OS
    case "$(uname -rs)" in
        *WSL2)
            packages=("${wsl_prereqs[@]}" "${packages[@]}" )
            ;;
    esac

    # Loop through each set of packages and each package, installing or pulling latest
    for package in ${packages[*]}; do
        echo "Checking for $(basename $package)...";
        ellipsis.list_packages | grep "$ELLIPSIS_PACKAGES/$(basename $package)" 2>&1 > /dev/null;
        if [ $? -ne 0 ]; then
            $ELLIPSIS_PATH/bin/ellipsis install $package;
        else
            $ELLIPSIS_PATH/bin/ellipsis pull $(basename $package);
        fi
    done
}

pkg.init() {
    # Add ellipsis bin to $PATH if it isn't there
    if [ ! "$(command -v ellipsis)" ]; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi
}

pkg.link() {
    : # Metapackage does not contain linkable files
}

pkg.unlink() {
    : # Metapackage does not contain linkable files 
}