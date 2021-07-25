#!/usr/bin/env bash

# Defaults
PACKAGES='thomshouse-ellipsis/desktop'
SSH_KEY=$HOME/.ssh/id_rsa
SSH_COMMENT="$(whoami)@$(hostname)"

# Check SSH key pair
if [ ! -f $SSH_KEY ] || [ ! -f $SSH_KEY.pub ]; then
    echo ""
    # If default pair not found, prompt for location
    read -e -p "SSH key location: [~/.ssh/id_rsa] " SSH_KEY
    if [ -z "$SSH_KEY" ]; then
        # If unspecified, fallback to default location
        SSH_KEY=$HOME/.ssh/id_rsa
    fi

    # If neither key is found, generate a new key
    if [ ! -f $SSH_KEY ] && [ ! -f $SSH_KEY.pub ]; then
        # Get a comment for the new key
        read -e -p "Comment to identify new SSH key: [$(whoami)@$(hostname)] " SSH_COMMENT
        if [ -z "$SSH_COMMENT" ]; then
            # Default to username@hostname
            SSH_COMMENT="$(whoami)@$(hostname)"
        fi
        SSH_DEFAULT_COMMENT="$SSH_COMMENT"
        # Generate the key
        ssh-keygen -f "$SSH_KEY" -t rsa -C "$SSH_COMMENT"
    elif [ ! -f $SSH_KEY ] || [ ! -f $SSH_KEY.pub ]; then
        # If one key is found but not the other, abort...  Something strange is going on.
        echo -e "\nERROR: Public and private key mismatch. Please check your SSH keys.\n"
        exit 1
    fi
fi

# Start SSH agent and add key -- or else this could get frustrating
echo -e "\nStarting temporary SSH agent...\n"
eval `ssh-agent` &>/dev/null
ssh-add "$SSH_KEY"

# Test to see if SSH key needs to be added to GitHub
ssh -i "$SSH_KEY" -T git@github.com 2>/dev/null
if [ $? -eq 255 ]; then
    # SSH key doesn't connect to GitHub -- Prompt to upload
    echo -e "\nYour SSH public key ($SSH_KEY.pub) does not appear to be associated with a GitHub account."
    echo -e "You will need to add your public key to your GitHub account.\n"
    
    # Try to be helpful and copy the public key to clipboard per OS
    if [ "$(command -v clip.exe)" ]; then
        # WSL
        head -c -1 "$SSH_KEY.pub" | clip.exe
        echo -e "For your convenience, your public key has been copied to your clipboard.\n"
    elif [ "$(command -v pbcopy)" ]; then
        # MacOS
        head -c -1 "$SSH_KEY.pub" | pbcopy
        echo -e "For your convenience, your public key has been copied to your clipboard.\n"
    elif [ "$(command -v xclip)" ]; then
        # Linux
        head -c -1 "$SSH_KEY.pub" | xclip -selection c
        echo -e "For your convenience, your public key has been copied to your clipboard.\n"
    elif [ "$(command -v edit)" ]; then
        # If clipboard isn't available, offer to open in the default editor
        read -e -p "Open public key in editor for copying? [Y/n] " OPEN_KEY_IN_EDITOR
        if [[ ! $OPEN_KEY_IN_EDITOR =~ ^[Nn][Oo]?$ ]]; then
            edit "$SSH_KEY.pub"
        fi
        echo ""
    fi

    # Optionally open up GitHub URLs if supported
    if [ -z "$BROWSER" ]; then
        # Look for common browsers/OS support if not set in environment
        browsers=( "explorer.exe" "open" "xdg-open" "gnome-open" "browsh" "w3m" "links2" "links" "lynx" )
        for b in "${browsers[@]}"; do
            if [ "$(command -v $b)" ]; then
                BROWSER="$b"
                break
            fi
        done
    fi
    if [ -n "$BROWSER" ]; then
        # Browser found -- Ask to open the URL
        prompt_github=1
        while [ $prompt_github -eq 1 ]; do
            read -e -p "Open GitHub URL for adding SSH key? [Y/n/?] " open_github_url
            case $open_github_url in
                [Nn]|[Nn][Oo])
                    echo ""
                    prompt_github=0
                    ;;
                [?]|[Hh]|[Hh][Ee][Ll][Pp])
                    echo -e "\nOpening GitHub Help page...\n"
                    $BROWSER "https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
                    ;;
                *)
                    echo -e "\nOpening GitHub Add SSH Key page...\n"
                    $BROWSER "https://github.com/settings/ssh/new"
                    prompt_github=0
                    ;;
            esac
        done
    fi

    # Pause to give time to upload the key
    read -n 1 -s -r -p "Please add your public key to your GitHub account, then press any key to continue..."
    read -s -t 0.001 # Clear any extra keycodes (e.g. arrows)
    echo ""
    # Retest key and loop until we have success
    ssh -i "$SSH_KEY" -T git@github.com 2>/dev/null
    while [ $? -eq 255 ]; do
        read -n 1 -s -r -p "Please add your public key to your GitHub account, then press any key to continue..."
        read -s -t 0.001 # Clear any extra keycodes (e.g. arrows)
        echo ""
        ssh -i "$SSH_KEY" -T git@github.com 2>/dev/null
    done
fi

curl -sL ellipsis.sh | PACKAGES="$PACKAGES" ELLIPSIS_PROTO='git' sh

# Stop the SSH agent
ssh-agent -k &>/dev/null
echo -e "\nTemporary SSH agent stopped.\n"