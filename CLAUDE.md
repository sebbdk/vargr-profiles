# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal development environment configuration repository containing:
- Shell profile configurations (bash/zsh)
- Installation scripts for development tools
- Arch Linux system setup scripts
- Project workspace organization

## Key Commands

### Initial Setup
```bash
./setup.sh          # Setup shell profiles (bash/zsh) with custom configurations
./install-all.sh    # Master script - installs zsh, tmux, nvm, and Claude Code
```

### Individual Installation Scripts
```bash
./install_zsh.sh    # Install zsh and oh-my-zsh
./install-tmux.sh   # Install tmux with custom configuration
./install-nvm.sh    # Install nvm and Node.js (LTS)
./install-claude.sh # Install Claude Code CLI globally via npm
```

### Arch Linux System Setup
```bash
./arch_setup/setup.sh              # Main Arch Linux system configuration
./arch_setup/install_chrome.sh     # Install Google Chrome on Arch
./arch_setup/kbd_auto_brightness.sh # Setup automatic keyboard backlight control
```

## Architecture

### Shell Configuration System
The repository uses a dual-shell approach with shared custom aliases:

- **`.zshvargr`**: Main zsh configuration with custom aliases, shortcuts, and functions
- **`.bash_profile`**: Bash fallback with equivalent aliases
- **`setup.sh`**: Orchestrates profile installation and plugin setup
  - Auto-installs oh-my-zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, fzf)
  - Configures tmux with mouse support and 256-color terminal
  - Updates shell rc files to source custom profiles

### Custom Aliases & Shortcuts
Defined in `.zshvargr` and `.bash_profile`:
- **Git**: `gls`, `gst`, `gct`, `gco`, `gbr`, `gl`
- **Navigation**: `dev` (→ ~/dev), `pro` (→ ~/dev/pro), `note` (opens logs in VSCode)
- **Arch Linux**: `kbdon`, `kbdlow`, `kbdoff` (keyboard backlight control)
- **Help**: Run `hint` command to display all available shortcuts

### Project Workspace Structure
- **`/pro`**: Project directory containing various development projects
  - Each subdirectory is an independent project
  - Some projects have their own CLAUDE.md files with project-specific rules
- **`/logs`**: Personal notes/logs workspace (opened with `note` alias)
- **`/arch_setup`**: System configuration scripts and themes

### Installation Script Pattern
All installation scripts follow this pattern:
1. Detect OS (macOS, Ubuntu/Debian, Arch Linux, Fedora/RHEL)
2. Check for existing installation
3. Install system dependencies
4. Install the tool (with proper permissions handling)
5. Configure PATH and shell integration
6. Verify installation success

The scripts handle both fresh installations and updates, with proper sudo usage and nvm-aware npm global installations.

## Important Notes

- This is a personal configuration repository - shell profiles assume user "vargr"
- Shell profiles display a hint menu on startup showing available shortcuts
- The `setup.sh` script is idempotent - safe to run multiple times
- Installation scripts check for existing installations before proceeding
- All scripts are designed to work across macOS, Ubuntu/Debian, and Arch Linux
- Git repository structure: uses master branch as main branch