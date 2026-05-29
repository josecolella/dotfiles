<div align="center">

# 🛠️ dotfiles

**My macOS shell, terminal, and editor setup — one command from a fresh machine to home.**

[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![zsh](https://img.shields.io/badge/shell-zsh-89e051?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Managed with Stow](https://img.shields.io/badge/managed%20with-GNU%20Stow-1793d1)](https://www.gnu.org/software/stow/)
[![Starship](https://img.shields.io/badge/prompt-starship-DD0B78?logo=starship&logoColor=white)](https://starship.rs/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

</div>

---

## ✨ Highlights

- 🔗 **Stow-managed** — every config is a symlink back into this repo, so edits are version-controlled the moment you save.
- 🐚 **zsh + oh-my-zsh + zplug**, prompted by **[starship](https://starship.rs/)** with sqlite-backed history ([zsh-histdb](https://github.com/larkery/zsh-histdb)).
- 🪟 **tmux** themed via **[oh-my-tmux](https://github.com/gpakosz/.tmux)** with TPM-managed plugins.
- ⌨️ **[LazyVim](https://www.lazyvim.org/)** Neovim, plus Zed and VS Code settings sharing one font (Monaspace Neon).
- 🔐 **SSH-signed git commits** out of the box.
- 🧩 **Clean work/personal split** — nothing work-specific or secret ever lands in this public repo (see below).
- 🚀 **One-shot bootstrap** — Homebrew, frameworks, and symlinks in a single idempotent script.

## 🖼️ Screenshots

> _Add a terminal + tmux screenshot here — e.g. `docs/terminal.png`._

## 🗂️ What's inside

| Package    | Links into                              | Configures                                      |
| ---------- | --------------------------------------- | ----------------------------------------------- |
| `zsh`      | `~/.zshrc`, `~/.zprofile`               | shell, oh-my-zsh, zplug, fzf, starship, histdb  |
| `tmux`     | `~/.config/tmux/tmux.conf.local`        | oh-my-tmux theme & key bindings                 |
| `git`      | `~/.gitconfig`, `~/.config/git/ignore`  | editor, SSH signing, push defaults, global ignore |
| `nvim`     | `~/.config/nvim/`                       | LazyVim (copilot, ruby, ts, json, markdown)     |
| `zed`      | `~/.config/zed/settings.json`           | Zed editor (Gruvbox, Monaspace)                 |
| `vscode`   | `~/Library/.../Code/User/settings.json` | VS Code (Monokai Pro, Prettier, format-on-save) |
| `gh`       | `~/.config/gh/config.yml`               | GitHub CLI defaults & aliases                   |
| `mise`     | `~/.config/mise/config.toml`            | pinned node & ruby versions                     |
| `ssh`      | `~/.ssh/config`                         | agent keychain, default identity                |
| `starship` | `~/.config/starship.toml`               | the prompt                                      |

## 🚀 Quick start

```sh
git clone https://github.com/josecolella/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs Homebrew + the [Brewfile](Brewfile), oh-my-zsh, oh-my-tmux, TPM, backs up
any colliding files to `~/.dotfiles-backup-<timestamp>/`, then stows everything. It's safe to re-run.

## 🔧 Manual install

```sh
brew install stow
cd ~/dotfiles
stow -nv zsh tmux git        # dry run — preview the symlinks
stow zsh tmux git nvim zed gh mise ssh starship vscode
```

Remove a package with `stow -D <package>`.

## 🔐 Work / personal split

This repo is **public**, so it carries only portable personal config. Anything secret or
work-specific is sourced from untracked local files that `bootstrap.sh` seeds from `templates/`:

- **`~/.zshrc.local`** — work env bootstrap, private aliases, machine-specific `PATH`. The tracked
  `.zshrc` ends with `[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local`.
- **`~/.gitconfig.local`** — your name, email, and signing key. The tracked `.gitconfig` pulls it in
  via `[include]`.

Both match `*.local` in [`.gitignore`](.gitignore), alongside `hosts.yml`, SSH private keys, AWS
credentials, and shell history — they can't be committed by accident.

## 🎨 Adding a package

1. `mkdir -p newtool/.config/newtool` and drop the config inside, mirroring its real `$HOME` path.
2. Add `newtool` to the `PACKAGES` array in `bootstrap.sh`.
3. `stow newtool`.

## 🙏 Credits

[oh-my-zsh](https://ohmyz.sh/) · [gpakosz/.tmux](https://github.com/gpakosz/.tmux) ·
[LazyVim](https://www.lazyvim.org/) · [starship](https://starship.rs/) ·
[GNU Stow](https://www.gnu.org/software/stow/)

## 📄 License

[MIT](LICENSE)
