#!/bin/bash

# Script to setup shell profiles with vargr configurations
# Handles both zsh (with oh-my-zsh) and bash fallback
# Run this once to configure everything

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHVARGR_PATH="$SCRIPT_DIR/.zshvargr"
BASH_PROFILE_PATH="$SCRIPT_DIR/.bash_profile"
ZSHRC_PATH="$HOME/.zshrc"
USER_BASH_PROFILE="$HOME/.bash_profile"

# Ensure the pro folder exists
mkdir -p ./pro

echo "Setting up shell profiles with vargr configurations..."
echo "Script location: $SCRIPT_DIR"

# Check if profile files exist
if [ ! -f "$ZSHVARGR_PATH" ]; then
    echo "Error: .zshvargr not found at $ZSHVARGR_PATH"
    exit 1
fi

if [ ! -f "$BASH_PROFILE_PATH" ]; then
    echo "Error: .bash_profile not found at $BASH_PROFILE_PATH"
    exit 1
fi

# Detect available shells
HAS_ZSH=false
HAS_BASH=false

if [ -f "$ZSHRC_PATH" ] && command -v zsh &> /dev/null; then
    HAS_ZSH=true
    echo "✓ Found zsh with .zshrc"
fi

if command -v bash &> /dev/null; then
    HAS_BASH=true
    echo "✓ Found bash"
fi

if [ "$HAS_ZSH" = false ] && [ "$HAS_BASH" = false ]; then
    echo "Error: No supported shell found (zsh or bash)"
    exit 1
fi

# Function to install oh-my-zsh plugins
install_plugin() {
    local plugin_name=$1
    local plugin_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    
    case $plugin_name in
        "zsh-autosuggestions")
            if [ ! -d "$plugin_path" ]; then
                echo "Installing zsh-autosuggestions..."
                git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_path"
            else
                echo "✓ zsh-autosuggestions already installed"
            fi
            ;;
        "zsh-syntax-highlighting")
            if [ ! -d "$plugin_path" ]; then
                echo "Installing zsh-syntax-highlighting..."
                git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_path"
            else
                echo "✓ zsh-syntax-highlighting already installed"
            fi
            ;;
        "fzf")
            if ! command -v fzf &> /dev/null; then
                echo "Installing fzf..."
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --all
            else
                echo "✓ fzf already installed"
            fi
            ;;
    esac
}

# Setup ZSH if available
if [ "$HAS_ZSH" = true ]; then
    echo ""
    echo "Setting up zsh configuration..."
    
    # Install plugins only if oh-my-zsh is available
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh plugins..."
        install_plugin "zsh-autosuggestions"
        install_plugin "zsh-syntax-highlighting" 
        install_plugin "fzf"
        
        # Auto-add plugins to .zshrc
        echo "Configuring plugins in .zshrc..."
        
        # Define desired plugins
        DESIRED_PLUGINS="git zsh-autosuggestions zsh-syntax-highlighting fzf docker npm node z copypath"
        
        # Check if plugins line exists
        if grep -q "^plugins=" "$ZSHRC_PATH"; then
            echo "Found existing plugins configuration"
            
            # Get current plugins line
            CURRENT_PLUGINS=$(grep "^plugins=" "$ZSHRC_PATH")
            
            # Add missing plugins
            for plugin in $DESIRED_PLUGINS; do
                if ! echo "$CURRENT_PLUGINS" | grep -q "$plugin"; then
                    echo "Adding plugin: $plugin"
                    # Insert plugin before the closing parenthesis
                    sed -i "s/)/ $plugin)/" "$ZSHRC_PATH"
                fi
            done
            
            echo "✓ Updated plugins configuration"
        else
            echo "No plugins line found, adding plugins configuration..."
            # Find a good spot to add plugins (after ZSH_THEME if it exists)
            if grep -q "^ZSH_THEME=" "$ZSHRC_PATH"; then
                sed -i "/^ZSH_THEME=/a\\nplugins=($DESIRED_PLUGINS)" "$ZSHRC_PATH"
            else
                # Add after the first few lines (likely after ZSH path)
                sed -i "5a\\nplugins=($DESIRED_PLUGINS)" "$ZSHRC_PATH"
            fi
            echo "✓ Added plugins configuration"
        fi
    else
        echo "⚠️  oh-my-zsh not found, skipping plugin installation"
        echo "   Install oh-my-zsh first for enhanced features"
    fi

    # Add .zshvargr source to .zshrc
    echo "Adding profile source to .zshrc..."
    
    SOURCE_LINE="source \"$ZSHVARGR_PATH\""
    
    # Check if already sourced
    if grep -q "source.*\.zshvargr" "$ZSHRC_PATH"; then
        echo "Found existing .zshvargr source in .zshrc"
        
        # Update the path if it's different
        if ! grep -q "$SOURCE_LINE" "$ZSHRC_PATH"; then
            echo "Updating .zshvargr path in .zshrc..."
            # Remove old source lines for .zshvargr
            sed -i '/source.*\.zshvargr/d' "$ZSHRC_PATH"
            # Add new source line at the end
            echo "" >> "$ZSHRC_PATH"
            echo "# Vargr custom profile" >> "$ZSHRC_PATH"
            echo "$SOURCE_LINE" >> "$ZSHRC_PATH"
        else
            echo "✓ .zshvargr already properly sourced in .zshrc"
        fi
    else
        echo "Adding .zshvargr source to .zshrc..."
        echo "" >> "$ZSHRC_PATH"
        echo "# Vargr custom profile" >> "$ZSHRC_PATH"
        echo "$SOURCE_LINE" >> "$ZSHRC_PATH"
        echo "✓ Added .zshvargr source to .zshrc"
    fi
fi

# Setup BASH if available
if [ "$HAS_BASH" = true ]; then
    echo ""
    echo "Setting up bash configuration..."
    
    BASH_SOURCE_LINE="source \"$BASH_PROFILE_PATH\""
    
    # Create .bash_profile if it doesn't exist
    if [ ! -f "$USER_BASH_PROFILE" ]; then
        echo "Creating ~/.bash_profile..."
        touch "$USER_BASH_PROFILE"
    fi
    
    # Check if already sourced
    if grep -q "source.*\.bash_profile.*vargr" "$USER_BASH_PROFILE" || grep -q "$BASH_SOURCE_LINE" "$USER_BASH_PROFILE"; then
        echo "Found existing vargr .bash_profile source"
        
        # Update the path if it's different
        if ! grep -q "$BASH_SOURCE_LINE" "$USER_BASH_PROFILE"; then
            echo "Updating .bash_profile path..."
            # Remove old source lines for vargr bash_profile
            sed -i '/source.*\.bash_profile.*vargr/d' "$USER_BASH_PROFILE"
            sed -i '/# Vargr bash profile/d' "$USER_BASH_PROFILE"
            # Add new source line at the end
            echo "" >> "$USER_BASH_PROFILE"
            echo "# Vargr bash profile" >> "$USER_BASH_PROFILE"
            echo "$BASH_SOURCE_LINE" >> "$USER_BASH_PROFILE"
        else
            echo "✓ Vargr .bash_profile already properly sourced"
        fi
    else
        echo "Adding vargr .bash_profile source to ~/.bash_profile..."
        echo "" >> "$USER_BASH_PROFILE"
        echo "# Vargr bash profile" >> "$USER_BASH_PROFILE"
        echo "$BASH_SOURCE_LINE" >> "$USER_BASH_PROFILE"
        echo "✓ Added vargr .bash_profile source"
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo ""

if [ "$HAS_ZSH" = true ]; then
    echo "ZSH Configuration:"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "• ✓ Plugins automatically added to .zshrc"
        echo "• Restart terminal or run: source ~/.zshrc"
        echo "• Enhanced features: fuzzy search (Ctrl+R), auto-suggestions, syntax highlighting"
    else
        echo "• Install oh-my-zsh for enhanced features"
        echo "• Restart terminal or run: source ~/.zshrc"
    fi
    echo ""
fi

if [ "$HAS_BASH" = true ]; then
    echo "BASH Configuration:"
    echo "• Restart terminal or run: source ~/.bash_profile"
    echo "• All vargr aliases available in bash"
    echo ""
fi

echo "Available shortcuts in both shells:"
echo "• gls, gst, gct, gco, gbr - git shortcuts"
echo "• dev, pro - folder navigation"
echo "• note - opens logs in vscode"
echo "• Type 'hint' to see all available shortcuts"