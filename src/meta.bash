#!/usr/bin/env bash

meta.install_packages() {
    # Determine which set of packages we'll install based on OS
    case $(os.platform) in
        wsl2)
            packages=("${wsl_prereqs[@]}" "${packages[@]}" )
            brew_packages=()
            cask_packages=()
            ;;
        linux)
            packages=("${linux_prereqs[@]}" "${packages[@]}" )
            brew_packages=()
            cask_packages=()
            choco_packages=()
            ;;
        osx)
            packages=("${macos_prereqs[@]}" "${packages[@]}" )
            apt_packages=()
            choco_packages=()
            ;;
        *)
            apt_packages=()
            brew_packages=()
            cask_packages=()
            choco_packages=()
            ;;
    esac

    # Loop through APT packages and install
    if [ ${#apt_packages[@]} -ne 0 ]; then
        DEBIAN_FRONTEND=noninteractive sudo apt-get update -y && sudo apt-get install -y ${apt_packages[@]}
    fi

    # Loop through each set of packages and each package, installing if it's not already installed
    for package in ${packages[*]}; do
        echo "Checking for $(basename $package)...";
        ellipsis.list_packages | grep "$ELLIPSIS_PACKAGES/$(basename $package)" 2>&1 > /dev/null;
        if [ $? -ne 0 ]; then
            $ELLIPSIS_PATH/bin/ellipsis install $package;
        fi
    done

    # Loop through each set of homebrew packages and install
    if [ ${#brew_packages[@]} -ne 0 ]; then
        brew install ${brew_packages[@]}
    fi
    if [ ${#cask_packages[@]} -ne 0 ]; then
        brew install --cask ${cask_packages[@]}
    fi

    # Loop through each set of choco packages and install
    if [ ${#choco_packages[@]} -ne 0 ]; then
        choco install ${choco_packages[@]} -y
    fi
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