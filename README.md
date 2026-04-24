# 🎯 Dotfiles

My personal configuration files for a productive development environment.

Quick setup with symlinks and automated installation script.

---

## 📋 What's Included

### Editor & IDE
- **IdeaVim** - Vim keybindings for WebStorm/IntelliJ
- Custom Vim configuration with leader key bindings

### Version Control
- **Git** - Global git configuration
- Default branch settings, user info, aliases

### Shell
- **Bash** - Bash configuration (.bashrc)
- **Zsh** - Zsh configuration (.zshrc)
- Aliases, functions, prompt customization

### Development Tools
- **Terminal** - Tmux configuration
- **Other** - EditorConfig, Prettier config

---

## 🚀 Quick Setup

### Clone & Install

```bash
# Clone repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run installer (creates symlinks)
bash install.sh

# Restart your IDE/terminal
```

### Manual Setup (if preferred)

```bash
# IdeaVim
cp ideavim/.ideavimrc ~/.ideavimrc

# Git
cp git/.gitconfig ~/.gitconfig

# Bash
cp shell/.bashrc ~/.bashrc

# Zsh  
cp shell/.zshrc ~/.zshrc
```

---

## 📁 Directory Structure

```
dotfiles/
├── .gitignore              # Git ignore rules
├── README.md               # This file
├── install.sh              # Automated installer
│
├── vim/                    # Vim/IdeaVim configs
│   └── .ideavimrc          # IdeaVim main config
│
├── git/                    # Git configuration
│   └── .gitconfig          # Git config
│
├── shell/                  # Shell configurations
│   ├── .bashrc             # Bash config
│   ├── .zshrc              # Zsh config
│   └── .bash_profile       # Bash profile
│
├── ide/                    # IDE configurations
│   └── webstorm/           # WebStorm specific
│
├── terminal/               # Terminal tools
│   └── .tmux.conf          # Tmux configuration
│
└── other/                  # Other configs
    ├── .editorconfig       # EditorConfig
    └── .prettierrc         # Prettier config
```

---

## ⚙️ IdeaVim Configuration

### Features
- **Leader Key**: Space (custom bindings)
- **Window Navigation**: Alt+hjkl
- **File Navigation**: Leader+ff (find file), Leader+fg (find in path)
- **Code Refactoring**: Leader+rn (rename), Leader+rm (extract method)
- **Terminal**: F12 (toggle), Leader+tt (alternative)
- **EasyMotion**: Leader+Leader+w/b/j/k
- **Claude AI**: Leader+af (fix), Leader+ae (explain), etc.

### Key Bindings

| Binding | Action |
| --- | --- |
| `<A-j/k/l/;>` | Navigate between windows |
| `<C-k/l>` | Move lines up/down |
| `<leader>ff` | Find file |
| `<leader>fg` | Find in path |
| `<leader>rn` | Rename element |
| `<leader>ca` | Show intention actions |
| `F12` | Toggle terminal |
| `<leader><leader>w` | EasyMotion jump to word |

---

## 🔄 Updating Configurations

### When you modify a config file

```bash
# 1. The changes are automatically in git (if using symlinks)
# or manually copy:
cp ~/.ideavimrc ~/dotfiles/ideavim/.ideavimrc

# 2. Commit changes
cd ~/dotfiles
git add ideavim/.ideavimrc
git commit -m "Update IdeaVim configuration"

# 3. Push to remote
git push origin main
```

### On another machine

```bash
cd ~/dotfiles
git pull origin main
bash install.sh
```

---

## 🔗 Symlinks (Recommended)

For automatic synchronization, use symlinks:

```bash
# Instead of copying, use symlinks:
ln -s ~/dotfiles/ideavim/.ideavimrc ~/.ideavimrc
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
```

This way, any changes sync immediately without copying.

---

## 💡 Tips & Tricks

### Backup Original Files

The installer automatically backs up existing files:
```
~/.ideavimrc → ~/.ideavimrc.backup.TIMESTAMP
```

### Using Different Configs Per Machine

Create machine-specific branches:
```bash
git checkout -b macos
git checkout -b linux
```

### Add New Configurations

1. Copy config to appropriate directory
2. Update `install.sh` with symlink
3. Commit and push

---

## 📝 IDE-Specific Notes

### WebStorm / IntelliJ IDEA
- IdeaVim plugin required (install from Plugins)
- EasyMotion plugin for enhanced navigation
- Configuration loads from `~/.ideavimrc`
- Restart IDE after config changes

### Other IDEs
- VS Code: Use Vim extension (not IdeaVim)
- Neovim: Use standard nvim config location
- Traditional Vim: Use `~/.vimrc`

---

## 🐛 Troubleshooting

### IdeaVim not loading config
```bash
# 1. Check file exists
cat ~/.ideavimrc

# 2. Reload config in IDE
:source ~/.ideavimrc

# 3. Restart IDE
# Close and reopen WebStorm
```

### Symlink conflicts
```bash
# Remove old file and recreate symlink
rm ~/.ideavimrc
ln -s ~/dotfiles/ideavim/.ideavimrc ~/.ideavimrc
```

### Install script permissions
```bash
# Make script executable
chmod +x ~/dotfiles/install.sh
bash install.sh
```

---

## 📚 Documentation

- `DOTFILES_SETUP.md` - Detailed setup guide
- `QUICK_DOTFILES_SETUP.md` - Quick start guide
- `KEYBOARD_TERMINAL_GUIDE.md` - Terminal keybindings
- `MERGE_REPORT.md` - Config merge details

---

## 🔐 Security Notes

- **Don't commit** sensitive data (passwords, tokens)
- Use `.local` files for machine-specific configs
- Set repository to **Private** if containing sensitive info
- Add patterns to `.gitignore` as needed

---

## 🤝 Contributing

Feel free to fork and adapt for your needs:

1. Clone the repository
2. Create your branch (`git checkout -b feature/new-config`)
3. Commit changes (`git commit -m 'Add new config'`)
4. Push to branch (`git push origin feature/new-config`)
5. Open a pull request

---

## 📄 License

MIT License - Feel free to use as template for your dotfiles.

---

## 🙏 Credits

- **IdeaVim** - Vim emulation for JetBrains IDEs
- **EasyMotion** - Enhanced navigation plugin
- Inspired by popular dotfiles repositories

---

## 📞 Support

If you encounter issues:

1. Check troubleshooting section above
2. Review `QUICK_DOTFILES_SETUP.md`
3. Run `bash install.sh -v` for verbose output
4. Check WebStorm/IDE logs

---

## 🚀 Next Steps

After installation:

1. **Restart IDE** - Changes take effect
2. **Test keybindings** - Try Space+ff, Alt+j, etc.
3. **Customize** - Modify as needed for your workflow
4. **Sync** - Keep multiple machines in sync with `git pull`

---

**Happy coding! 🎉**

For updates and syncing across machines:
```bash
cd ~/dotfiles
git pull origin main
bash install.sh
```
