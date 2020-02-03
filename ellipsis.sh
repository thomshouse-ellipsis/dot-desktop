#!/usr/bin/env bash

packages=(
    thomshouse-ellipsis/zsh
);
    
pkg.install() {
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