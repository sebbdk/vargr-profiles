#!/bin/bash

# Script to install tmux on different operating systems
# Supports Arch Linux, Ubuntu/Debian, and macOS

echo "Tmux Installation Script"
echo "======================="
echo ""

# Function to detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

# Function to install tmux on Arch Linux
install_arch() {
    echo "Installing tmux on Arch Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --needed tmux
        echo "✓ Tmux installed via pacman"
    else
        echo "❌ Error: pacman not found. Are you sure this is Arch Linux?"
        exit 1
    fi
}

# Function to install tmux on Ubuntu/Debian
install_ubuntu() {
    echo "Installing tmux on Ubuntu/Debian..."

    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y tmux
        echo "✓ Tmux installed via apt"
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y tmux
        echo "✓ Tmux installed via apt-get"
    else
        echo "❌ Error: apt/apt-get not found. Are you sure this is Ubuntu/Debian?"
        exit 1
    fi
}

# Function to install tmux on macOS
install_macos() {
    echo "Installing tmux on macOS..."

    # Check if Homebrew is installed
    if command -v brew &> /dev/null; then
        echo "Found Homebrew, installing tmux..."
        brew install tmux
        echo "✓ Tmux installed via Homebrew"
    else
        echo "❌ Homebrew not found. Installing Homebrew first..."
        echo "Visit https://brew.sh for installation instructions, or run:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        echo ""
        echo "After installing Homebrew, run this script again."
        exit 1
    fi
}

# Main installation logic
main() {
    # Check if tmux is already installed
    if command -v tmux &> /dev/null; then
        echo "✓ Tmux is already installed!"
        tmux -V
        echo ""
        echo "To configure tmux with mouse scrolling and 256 colors, run: ./setup.sh"
        exit 0
    fi

    # Detect operating system
    OS=$(detect_os)
    echo "Detected OS: $OS"
    echo ""

    case $OS in
        "arch")
            install_arch
            ;;
        "ubuntu")
            install_ubuntu
            ;;
        "macos")
            install_macos
            ;;
        "unknown")
            echo "❌ Unsupported operating system detected."
            echo "This script supports:"
            echo "• Arch Linux (via pacman)"
            echo "• Ubuntu/Debian (via apt)"
            echo "• macOS (via Homebrew)"
            echo ""
            echo "Please install tmux manually for your system."
            exit 1
            ;;
    esac

    echo ""
    echo "🎉 Tmux installation complete!"
    echo ""

    # Verify installation
    if command -v tmux &> /dev/null; then
        echo "✓ Installation verified:"
        tmux -V
        echo ""
        echo "Next steps:"
        echo "1. Run './setup.sh' to configure tmux with mouse scrolling and 256 colors"
        echo "2. Start tmux with: tmux"
        echo "3. Create new panes: Ctrl+b then % (vertical) or \" (horizontal)"
        echo "4. Switch panes: Ctrl+b then arrow keys"
        echo "5. Detach session: Ctrl+b then d"
        echo "6. List sessions: tmux list-sessions"
        echo "7. Attach to session: tmux attach"
    else
        echo "❌ Installation failed. Please try installing tmux manually."
        exit 1
    fi
}

# Run main function
main