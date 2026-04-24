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

## 🚀 Setup on a new machine

### Prerequisites

- `git`, `bash` (4+), and `zsh` installed
- Write access to `$HOME` and `$XDG_CONFIG_HOME` (defaults to `~/.config`)
- Optional: JetBrains IDE with the IdeaVim plugin (for `.ideavimrc`)

On Debian/Ubuntu: `sudo apt install git zsh`. On macOS: `git` and `zsh` ship with the system; install Xcode Command Line Tools with `xcode-select --install` if missing.

### 1. Clone the repo

The install script works from any path, but the rest of this README assumes `~/dotfiles`:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the installer

```bash
bash scripts/install-xdg.sh
```

What it does:
- creates `$XDG_CONFIG_HOME`, `~/.local/bin`, `$XDG_DATA_HOME`, `$XDG_STATE_HOME/zsh` if missing
- symlinks `~/.zshenv`, `~/.bashrc`, `~/.ideavimrc`, and the `zsh`/`bash` configs under `~/.config/`
- backs up any pre-existing regular file to `<path>.backup.<timestamp>` before replacing it

The script is idempotent — re-running it is safe and only re-links what changed.

### 3. Start a fresh shell

The new `~/.zshenv` sets `ZDOTDIR`, which only takes effect in a new shell:

```bash
exec zsh   # or: exec bash
```

### 4. Verify

```bash
bash scripts/verify.sh
```

Exit code `0` = healthy. On failure it prints which symlink, env var, or syntax check is broken.

### 5. (Optional) IDE setup

For WebStorm / IntelliJ:
1. Install the **IdeaVim** and **IdeaVim-EasyMotion** plugins.
2. Restart the IDE — it picks up `~/.ideavimrc` automatically.

---

## 🔄 Migration from pre-XDG layout

The repo previously kept configs under `ideavim/`, `shell/`, etc. It now follows the XDG Base Directory spec (`~/.config/<tool>/`). If you cloned before this change, run:

```bash
git pull
bash scripts/migrate-xdg.sh
exec $SHELL
bash scripts/verify.sh
```

Rollback: a tar snapshot of the pre-migration state is saved at `~/.cache/dotfiles-backups/pre-xdg.<timestamp>.tar.gz`. Restore with `git reset --hard HEAD && tar xzf ~/.cache/dotfiles-backups/pre-xdg.<timestamp>.tar.gz -C ~/dotfiles`.

---

## 📁 Directory Structure

```
dotfiles/
├── .gitignore
├── README.md
├── CLAUDE.md                   # Agent guidance
├── .zshenv                     # → ~/.zshenv (sets ZDOTDIR)
├── .bashrc                     # → ~/.bashrc (thin XDG wrapper)
│
├── .config/                    # mirrors ~/.config/
│   ├── zsh/
│   │   ├── .zshrc              # → ~/.config/zsh/.zshrc
│   │   └── .zprofile           # → ~/.config/zsh/.zprofile
│   ├── bash/
│   │   └── bashrc              # → ~/.config/bash/bashrc
│   ├── ideavim/
│   │   └── ideavimrc           # → ~/.ideavimrc (JetBrains reads $HOME)
│   ├── vim/                    # placeholder, empty
│   └── nvim/                   # placeholder, empty
│
└── scripts/
    ├── lib/common.sh           # shared bash helpers
    ├── install-xdg.sh          # create symlinks
    ├── migrate-xdg.sh          # one-shot repo layout migration
    └── verify.sh               # health check (exit 0/1)
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

Configs are symlinks into this repo, so edits are already in git:

```bash
cd ~/dotfiles
git status
git commit -am "Update config"
git push
```

### On another machine

```bash
cd ~/dotfiles
git pull
bash scripts/install-xdg.sh
```

---

## 💡 Tips & Tricks

### Backup Original Files

The installer automatically backs up any existing file before replacing it with a symlink:
```
~/.ideavimrc → ~/.ideavimrc.backup.TIMESTAMP
```

### Adding a new config

1. Drop the config under `.config/<tool>/` in this repo.
2. Add a matching `link_file` call to `scripts/install-xdg.sh`.
3. Re-run `bash scripts/install-xdg.sh`.

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
# Re-run the installer; it backs up conflicts and relinks.
bash scripts/install-xdg.sh
```

### Verify installation
```bash
bash scripts/verify.sh
```

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
2. Run `bash scripts/verify.sh` to diagnose
3. Check WebStorm/IDE logs

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
git pull
bash scripts/install-xdg.sh
```
