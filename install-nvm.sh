#!/bin/bash

# NVM (Node Version Manager) Installation Script
# Works on macOS, Ubuntu/Debian, and Arch Linux

set -e  # Exit on any error

echo "Node Version Manager (nvm) Installation"
echo "======================================="
echo ""

# Function to detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
        echo "ubuntu"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Function to install prerequisites based on OS
install_prerequisites() {
    local os=$1
    echo "Installing prerequisites for $os..."

    case "$os" in
        "macos")
            # Check if Homebrew is available
            if command -v brew &> /dev/null; then
                brew install curl git
            else
                echo "Note: Homebrew not found. curl and git should be available by default on macOS."
            fi
            ;;
        "ubuntu"|"debian")
            sudo apt update
            sudo apt install -y curl git build-essential
            ;;
        "arch"|"manjaro")
            sudo pacman -S --needed curl git base-devel
            ;;
        "fedora"|"centos"|"rhel"|"rocky")
            if command -v dnf &> /dev/null; then
                sudo dnf install -y curl git gcc-c++ make
            elif command -v yum &> /dev/null; then
                sudo yum install -y curl git gcc-c++ make
            fi
            ;;
        *)
            echo "⚠️  Unknown OS: $os. Assuming curl and git are available."
            ;;
    esac
}

# Function to determine shell config file
get_shell_config() {
    local shell_name=$(basename "$SHELL")
    case "$shell_name" in
        "zsh")
            echo "$HOME/.zshrc"
            ;;
        "bash")
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        "fish")
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.bashrc"
            ;;
    esac
}

# Function to install nvm
install_nvm() {
    echo "Installing nvm..."

    # Check if nvm is already installed
    if [ -d "$HOME/.nvm" ]; then
        echo "✓ nvm directory already exists"

        # Source nvm to check version
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        if command -v nvm &> /dev/null; then
            echo "✓ nvm is already installed: $(nvm --version)"
            return 0
        else
            echo "⚠️  nvm directory exists but nvm command not found. Reinstalling..."
        fi
    fi

    # Download and install nvm
    echo "Downloading nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    if [ ! -d "$HOME/.nvm" ]; then
        echo "❌ Failed to install nvm"
        exit 1
    fi

    echo "✓ nvm installed successfully"
}

# Function to configure shell
configure_shell() {
    echo "Configuring shell integration..."

    local config_file=$(get_shell_config)
    echo "Using config file: $config_file"

    # Create config file if it doesn't exist
    touch "$config_file"

    # Check if nvm configuration already exists
    if grep -q "NVM_DIR" "$config_file" 2>/dev/null; then
        echo "✓ nvm is already configured in $config_file"
        return 0
    fi

    # Add nvm configuration to shell config
    echo "" >> "$config_file"
    echo "# NVM configuration" >> "$config_file"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$config_file"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$config_file"
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> "$config_file"

    echo "✓ nvm configuration added to $config_file"
}

# Function to install Node.js
install_nodejs() {
    echo "Installing Node.js..."

    # Source nvm in current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if ! command -v nvm &> /dev/null; then
        echo "❌ nvm command not found. Please restart your terminal and try again."
        return 1
    fi

    # Install latest LTS Node.js
    echo "Installing latest LTS Node.js..."
    nvm install --lts
    nvm use --lts
    nvm alias default node

    echo "✓ Node.js installed: $(node --version)"
    echo "✓ npm installed: $(npm --version)"
}

# Main installation function
main() {
    echo "Starting nvm installation..."
    echo ""

    # Detect operating system
    OS=$(detect_os)
    echo "Detected OS: $OS"
    echo ""

    # Install prerequisites
    install_prerequisites "$OS"
    echo ""

    # Install nvm
    install_nvm
    echo ""

    # Configure shell
    configure_shell
    echo ""

    # Try to install Node.js in current session
    echo "Attempting to install Node.js in current session..."
    if install_nodejs; then
        echo ""
        echo "🎉 nvm and Node.js installation complete!"
    else
        echo ""
        echo "🎉 nvm installation complete!"
        echo ""
        echo "⚠️  To complete the setup:"
        echo "1. Restart your terminal or run: source $(get_shell_config)"
        echo "2. Install Node.js: nvm install --lts"
        echo "3. Set default: nvm alias default node"
    fi

    echo ""
    echo "Installation summary:"
    echo "• nvm: $HOME/.nvm"
    echo "• Shell config: $(get_shell_config)"
    echo ""

    echo "Useful nvm commands:"
    echo "• List available versions: nvm list-remote"
    echo "• Install specific version: nvm install 18.17.0"
    echo "• Use specific version: nvm use 18.17.0"
    echo "• List installed versions: nvm list"
    echo "• Set default version: nvm alias default 18.17.0"
    echo "• Current version: node --version"
}

# Run main function
main