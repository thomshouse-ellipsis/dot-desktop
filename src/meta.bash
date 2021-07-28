#!/usr/bin/env bash

meta.install_packages() {
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

meta.check_init_autoload() {
    # Check to see if ellipsis init is loaded
    ELLIPSIS_RELPATH=$(path.relative_to_home "$ELLIPSIS_PATH")
    grep -Eq "[.].+($ELLIPSIS_RELPATH|$ELLIPSIS_PATH)/init[.]sh" "$HOME/"{.bashrc,.zshrc,.localrc} &>/dev/null
    if [ $? -ne 0 ]; then
        # Check for eligible .rc files
        for rcfile in .bashrc .zshrc .localrc; do
            # For each file, check to see if it exists, is not symlinked, and does not source ellipsis init
            if [[ -f "$HOME/$rcfile" && ! -L "$HOME/$rcfile" && ! $(grep -Fxq ". $ELLIPSIS_RELPATH//init.sh" "$HOME/$rcfile") ]]; then
                # Ask to add the init script to each valid file
                read -e -p "Do you want to add ellipsis init to $rcfile? [Y/n] " ADD_TO_RC
                if [[ ! $ADD_TO_RC =~ ^[Nn][Oo]?$ ]]; then
                    # Add to the script if selected
                    echo -e "\n# Load ellipsis init system" >> "$HOME/$rcfile"
                    echo -e ". $ELLIPSIS_RELPATH/init.sh\n" >> "$HOME/$rcfile"
                    break
                fi
            fi
        done
    fi
    # Check again to see if ellipsis init is loaded anywhere. If not, ask.
    grep -Eq "[.].+($ELLIPSIS_RELPATH|$ELLIPSIS_PATH)/init[.]sh" "$HOME/".*rc &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Please add the ellipsis init script to your profile startup files. Ex:"
        echo "  . $ELLIPSIS_RELPATH/init.sh"
    fi
}

pkg.link() {
    : # Metapackage does not contain linkable files
}

pkg.unlink() {
    : # Metapackage does not contain linkable files 
}