#!/bin/bash

# Script to install zsh and oh-my-zsh on various Linux distributions
# Supports: Debian/Ubuntu, Rocky Linux/CentOS/RHEL, Arch Linux

set -e  # Exit on any error

echo "Installing zsh and oh-my-zsh..."
echo "Detecting Linux distribution..."

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    VER=$(lsb_release -sr)
elif [ -f /etc/redhat-release ]; then
    OS="centos"
    VER=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | head -1)
elif [ -f /etc/arch-release ]; then
    OS="arch"
    VER=""
else
    echo "❌ Cannot detect Linux distribution"
    exit 1
fi

echo "Detected: $OS $VER"

# Function to install zsh based on distribution
install_zsh() {
    case "$OS" in
        "ubuntu"|"debian")
            echo "Installing zsh on Debian/Ubuntu..."
            sudo apt update
            sudo apt install -y zsh curl git
            ;;
        "rocky"|"centos"|"rhel"|"fedora")
            echo "Installing zsh on Rocky/CentOS/RHEL..."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y zsh curl git util-linux-user
            elif command -v yum &> /dev/null; then
                sudo yum install -y zsh curl git util-linux-user
            else
                echo "❌ Neither dnf nor yum package manager found"
                exit 1
            fi
            ;;
        "arch"|"manjaro")
            echo "Installing zsh on Arch Linux..."
            sudo pacman -S --noconfirm zsh curl git
            ;;
        *)
            echo "❌ Unsupported distribution: $OS"
            echo "Supported: Debian, Ubuntu, Rocky Linux, CentOS, RHEL, Fedora, Arch Linux"
            exit 1
            ;;
    esac
}

# Check if zsh is already installed
if command -v zsh &> /dev/null; then
    echo "✓ zsh is already installed: $(zsh --version)"
else
    echo "Installing zsh..."
    install_zsh
    echo "✓ zsh installed successfully"
fi

# Install oh-my-zsh if not already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✓ oh-my-zsh is already installed"
else
    echo "Installing oh-my-zsh..."
    
    # Download and install oh-my-zsh non-interactively
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "✓ oh-my-zsh installed successfully"
    else
        echo "❌ Failed to install oh-my-zsh"
        exit 1
    fi
fi

# Offer to change default shell to zsh
echo ""
echo "🎉 Installation complete!"
echo ""

CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Your current shell is: $CURRENT_SHELL"
    echo ""
    echo "To make zsh your default shell, run:"
    echo "  chsh -s \$(which zsh)"
    echo ""
    echo "Or manually change it:"
    
    case "$OS" in
        "ubuntu"|"debian")
            echo "  sudo chsh -s /usr/bin/zsh \$USER"
            ;;
        "rocky"|"centos"|"rhel"|"fedora")
            echo "  sudo chsh -s /bin/zsh \$USER"
            ;;
        "arch"|"manjaro")
            echo "  chsh -s /usr/bin/zsh"
            ;;
    esac
    
    echo ""
    echo "After changing shell, log out and log back in."
else
    echo "✓ zsh is already your default shell"
fi

echo ""
echo "Next steps:"
echo "1. Change your default shell to zsh (see instructions above)"
echo "2. Log out and log back in (or restart terminal)"
echo "3. Run ./setup_zsh.sh to configure your vargr profile"
echo ""
echo "Installation locations:"
echo "• zsh: $(which zsh 2>/dev/null || echo 'not found in PATH')"
echo "• oh-my-zsh: $HOME/.oh-my-zsh"
echo "• zsh config: $HOME/.zshrc"