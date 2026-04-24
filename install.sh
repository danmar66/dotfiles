#!/bin/bash

# ============================================================================
# Dotfiles Installer Script
# ============================================================================
# This script creates symbolic links for all configuration files
# Usage: bash install.sh
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Installing Dotfiles               ║${NC}"
echo -e "${BLUE}║     From: ${DOTFILES_DIR}${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

link_file() {
    local src=$1
    local dst=$2
    local description=$3
    
    # Create directory if doesn't exist
    local dst_dir=$(dirname "$dst")
    if [ ! -d "$dst_dir" ]; then
        mkdir -p "$dst_dir"
        echo -e "${BLUE}➜${NC} Created directory: $dst_dir"
    fi
    
    # Handle existing file
    if [ -e "$dst" ]; then
        if [ -L "$dst" ]; then
            # Already a symlink
            if [ "$(readlink "$dst")" = "$src" ]; then
                echo -e "${GREEN}✓${NC} Already linked: $description"
                return 0
            else
                # Different symlink, replace it
                rm "$dst"
                echo -e "${YELLOW}⟳${NC} Updated symlink: $description"
            fi
        else
            # Regular file, backup it
            backup_file="$dst.backup.$(date +%s)"
            mv "$dst" "$backup_file"
            echo -e "${YELLOW}⚠${NC}  Backed up: $dst → $backup_file"
        fi
    fi
    
    # Create symlink
    ln -s "$src" "$dst"
    echo -e "${GREEN}✓${NC} Linked: $description"
}

check_file_exists() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠${NC}  File not found: $file (skipping)"
        return 1
    fi
    return 0
}

# ============================================================================
# VIM / IDEAVIM
# ============================================================================

echo -e "${BLUE}Setting up Vim/IdeaVim...${NC}"

if check_file_exists "$DOTFILES_DIR/vim/.ideavimrc"; then
    link_file "$DOTFILES_DIR/vim/.ideavimrc" "$HOME/.ideavimrc" "IdeaVim config"
fi

echo ""

# ============================================================================
# GIT
# ============================================================================

echo -e "${BLUE}Setting up Git...${NC}"

if check_file_exists "$DOTFILES_DIR/git/.gitconfig"; then
    link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig" "Git config"
fi

echo ""

# ============================================================================
# SHELL
# ============================================================================

echo -e "${BLUE}Setting up Shell...${NC}"

if check_file_exists "$DOTFILES_DIR/shell/.bashrc"; then
    link_file "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc" "Bash config"
fi

if check_file_exists "$DOTFILES_DIR/shell/.zshrc"; then
    link_file "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc" "Zsh config"
fi

if check_file_exists "$DOTFILES_DIR/shell/.bash_profile"; then
    link_file "$DOTFILES_DIR/shell/.bash_profile" "$HOME/.bash_profile" "Bash profile"
fi

echo ""

# ============================================================================
# IDE - WebStorm
# ============================================================================

echo -e "${BLUE}Setting up IDE configurations...${NC}"

# WebStorm paths (uncomment for your OS)
# macOS
WEBSTORM_MACOS="$HOME/Library/Preferences/WebStorm*/options"
# Linux
WEBSTORM_LINUX="$HOME/.config/JetBrains/WebStorm*/options"

# Check if WebStorm config exists and link if needed
# (Usually IDE settings are synced via IDE itself, but you can customize here)
# if [ -d "$WEBSTORM_MACOS" ]; then
#     link_file "$DOTFILES_DIR/ide/webstorm/settings.xml" \
#         "$WEBSTORM_MACOS/settings.xml" "WebStorm settings"
# fi

echo -e "${YELLOW}ℹ${NC}  IDE settings usually sync through IDE"
echo -e "${YELLOW}ℹ${NC}  IdeaVim config is already linked (.ideavimrc)"

echo ""

# ============================================================================
# TERMINAL
# ============================================================================

echo -e "${BLUE}Setting up Terminal configurations...${NC}"

if check_file_exists "$DOTFILES_DIR/terminal/.tmux.conf"; then
    link_file "$DOTFILES_DIR/terminal/.tmux.conf" "$HOME/.tmux.conf" "Tmux config"
fi

echo ""

# ============================================================================
# OTHER
# ============================================================================

echo -e "${BLUE}Setting up other configurations...${NC}"

if check_file_exists "$DOTFILES_DIR/other/.editorconfig"; then
    link_file "$DOTFILES_DIR/other/.editorconfig" "$HOME/.editorconfig" "EditorConfig"
fi

if check_file_exists "$DOTFILES_DIR/other/.prettierrc"; then
    link_file "$DOTFILES_DIR/other/.prettierrc" "$HOME/.prettierrc" "Prettier config"
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Installation Complete!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Linked configurations:${NC}"
echo "  • IdeaVim (.ideavimrc)"
echo "  • Git (.gitconfig)"
echo "  • Shell (.bashrc, .zshrc)"
echo "  • Terminal (if applicable)"
echo "  • Other configs (if applicable)"
echo ""
echo -e "${YELLOW}Notes:${NC}"
echo "  • Some changes require IDE restart"
echo "  • Check IDE-specific settings through GUI if needed"
echo "  • Backup files created with .backup suffix"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Restart WebStorm: Cmd+Q (macOS) or close and reopen"
echo "  2. Test your configurations"
echo "  3. Run 'git status' to see changes"
echo "  4. Commit and push updates"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
