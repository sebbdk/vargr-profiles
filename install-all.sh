#!/bin/bash

# Master Installation Script
# Runs all installation scripts in order

echo "🚀 Installing all development tools..."
echo ""

./install_zsh.sh
echo ""

./install-tmux.sh
echo ""

./install-nvm.sh
echo ""

./install-claude.sh
echo ""

echo "🎉 All installations complete!"