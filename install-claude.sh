#!/bin/bash

# Claude Code Installation Script
# Works on macOS, Ubuntu/Debian, and Arch Linux
# Requires Node.js/npm to be installed

set -e  # Exit on any error

echo "Claude Code Installation"
echo "========================"
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

# Function to check if Node.js and npm are installed
check_nodejs() {
    echo "Checking Node.js and npm..."

    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed"
        echo ""
        echo "Please install Node.js first:"
        echo "• Run: ./install-nvm.sh"
        echo "• Or install Node.js from: https://nodejs.org"
        echo "• Or use your system package manager"
        exit 1
    fi

    if ! command -v npm &> /dev/null; then
        echo "❌ npm is not installed"
        echo ""
        echo "npm should come with Node.js. Please reinstall Node.js."
        exit 1
    fi

    echo "✓ Node.js: $(node --version)"
    echo "✓ npm: $(npm --version)"
}

# Function to install system dependencies
install_dependencies() {
    local os=$1
    echo "Installing system dependencies for $os..."

    case "$os" in
        "macos")
            # On macOS, most dependencies should be available
            echo "✓ macOS dependencies should be available"
            ;;
        "ubuntu"|"debian")
            echo "Installing build essentials..."
            sudo apt update
            sudo apt install -y build-essential python3
            ;;
        "arch"|"manjaro")
            echo "Installing build essentials..."
            sudo pacman -S --needed base-devel python
            ;;
        "fedora"|"centos"|"rhel"|"rocky")
            echo "Installing build essentials..."
            if command -v dnf &> /dev/null; then
                sudo dnf groupinstall -y "Development Tools"
                sudo dnf install -y python3
            elif command -v yum &> /dev/null; then
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y python3
            fi
            ;;
        *)
            echo "⚠️  Unknown OS: $os. Assuming build tools are available."
            ;;
    esac
}

# Function to check if Claude Code is already installed
check_existing_installation() {
    if command -v claude &> /dev/null; then
        echo "✓ Claude Code is already installed"
        echo "Current version: $(claude --version 2>/dev/null || echo 'unknown')"
        echo ""
        read -p "Do you want to update Claude Code? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping installation."
            exit 0
        fi
        return 1  # Indicate update needed
    fi
    return 0  # New installation
}

# Function to install Claude Code
install_claude() {
    echo "Installing Claude Code..."

    # Check npm global directory permissions
    if [[ "$(npm config get prefix)" == "/usr"* ]] && [[ "$EUID" -ne 0 ]]; then
        echo "⚠️  npm global directory requires sudo. Consider using nvm for better permissions."
        echo "Installing with sudo..."
        sudo npm install -g @anthropic/claude-code
    else
        npm install -g @anthropic/claude-code
    fi

    # Verify installation
    if command -v claude &> /dev/null; then
        echo "✓ Claude Code installed successfully"
        echo "Version: $(claude --version 2>/dev/null || echo 'installed')"
    else
        echo "❌ Claude Code installation failed"
        echo ""
        echo "Troubleshooting tips:"
        echo "• Check npm global bin directory: npm config get prefix"
        echo "• Add npm global bin to PATH: export PATH=\$(npm config get prefix)/bin:\$PATH"
        echo "• Consider using nvm for better npm permissions"
        exit 1
    fi
}

# Function to setup Claude Code configuration
setup_claude() {
    echo "Setting up Claude Code configuration..."

    # Check if config directory exists
    local config_dir="$HOME/.config/claude-code"
    if [ ! -d "$config_dir" ]; then
        echo "Creating config directory: $config_dir"
        mkdir -p "$config_dir"
    fi

    echo "✓ Configuration directory ready: $config_dir"
    echo ""
    echo "Next steps for Claude Code setup:"
    echo "1. Run 'claude login' to authenticate"
    echo "2. Run 'claude --help' to see available commands"
    echo "3. Start coding with Claude!"
}

# Function to add Claude to PATH if needed
update_path() {
    echo "Checking PATH configuration..."

    # Get npm global bin directory
    local npm_bin
    if command -v npm &> /dev/null; then
        npm_bin=$(npm config get prefix 2>/dev/null)/bin
    else
        echo "⚠️  npm not found, cannot determine global bin directory"
        return
    fi

    # Check if npm bin is in PATH
    if [[ ":$PATH:" == *":$npm_bin:"* ]]; then
        echo "✓ npm global bin directory is in PATH"
        return
    fi

    echo "Adding npm global bin to PATH..."

    # Determine shell config file
    local shell_name=$(basename "$SHELL")
    local config_file
    case "$shell_name" in
        "zsh")
            config_file="$HOME/.zshrc"
            ;;
        "bash")
            if [[ "$OSTYPE" == "darwin"* ]]; then
                config_file="$HOME/.bash_profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
        *)
            config_file="$HOME/.bashrc"
            ;;
    esac

    # Add to PATH if not already there
    if ! grep -q "npm config get prefix" "$config_file" 2>/dev/null; then
        echo "" >> "$config_file"
        echo "# Add npm global bin to PATH" >> "$config_file"
        echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> "$config_file"
        echo "✓ Added npm global bin to PATH in $config_file"
        echo "Please restart your terminal or run: source $config_file"
    else
        echo "✓ npm global bin PATH configuration already exists"
    fi
}

# Main installation function
main() {
    echo "Starting Claude Code installation..."
    echo ""

    # Detect operating system
    OS=$(detect_os)
    echo "Detected OS: $OS"
    echo ""

    # Check Node.js and npm
    check_nodejs
    echo ""

    # Check existing installation
    if check_existing_installation; then
        echo "New installation detected."
    else
        echo "Updating existing installation."
    fi
    echo ""

    # Install system dependencies
    install_dependencies "$OS"
    echo ""

    # Install Claude Code
    install_claude
    echo ""

    # Setup configuration
    setup_claude
    echo ""

    # Update PATH if needed
    update_path
    echo ""

    echo "🎉 Claude Code installation complete!"
    echo ""

    echo "Getting started:"
    echo "• Authenticate: claude login"
    echo "• Get help: claude --help"
    echo "• Start a project: claude"
    echo "• Check version: claude --version"
    echo ""

    echo "Installation summary:"
    echo "• Claude Code: $(which claude 2>/dev/null || echo 'installed globally')"
    echo "• Config directory: $HOME/.config/claude-code"
    echo "• Node.js: $(node --version)"
    echo "• npm: $(npm --version)"
    echo ""

    if ! command -v claude &> /dev/null; then
        echo "⚠️  If 'claude' command is not found, try:"
        echo "• Restart your terminal"
        echo "• Run: source ~/.zshrc (or ~/.bashrc)"
        echo "• Check PATH: echo \$PATH"
    fi
}

# Run main function
main