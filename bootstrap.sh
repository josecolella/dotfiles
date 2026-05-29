#!/usr/bin/env bash
# bootstrap.sh — set up these dotfiles on a fresh macOS machine.
# Idempotent: safe to run repeatedly. github.com/josecolella/dotfiles
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Stow packages to link into $HOME (each is a top-level dir in this repo).
PACKAGES=(zsh tmux git nvim zed gh mise ssh starship vscode)

log()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$1"; }

# 1. Homebrew --------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
log "Installing Brewfile dependencies…"
brew bundle --file="$DOTFILES/Brewfile"

# 2. oh-my-zsh -------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing oh-my-zsh…"
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
HISTDB="$HOME/.oh-my-zsh/custom/plugins/zsh-histdb"
if [ ! -d "$HISTDB" ]; then
  log "Installing zsh-histdb…"
  git clone https://github.com/larkery/zsh-histdb "$HISTDB"
fi

# 3. oh-my-tmux + TPM ------------------------------------------------------
OHMYTMUX="$HOME/.local/share/tmux/oh-my-tmux"
if [ ! -d "$OHMYTMUX" ]; then
  log "Installing oh-my-tmux…"
  git clone https://github.com/gpakosz/.tmux.git "$OHMYTMUX"
fi
mkdir -p "$HOME/.config/tmux"
ln -sf "$OHMYTMUX/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
TPM="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM" ]; then
  log "Installing TPM (tmux plugin manager)…"
  git clone https://github.com/tmux-plugins/tpm "$TPM"
fi

# 4. Local override files --------------------------------------------------
[ -f "$HOME/.zshrc.local" ]    || { log "Seeding ~/.zshrc.local";    cp "$DOTFILES/templates/zshrc.local.example"    "$HOME/.zshrc.local"; }
[ -f "$HOME/.gitconfig.local" ] || { log "Seeding ~/.gitconfig.local"; cp "$DOTFILES/templates/gitconfig.local.example" "$HOME/.gitconfig.local"; }

# 5. Back up colliding real files, then stow ------------------------------
log "Backing up any conflicting files to $BACKUP …"
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$target" "$BACKUP/$rel"
      warn "backed up $target"
    fi
  done < <(find "$DOTFILES/$pkg" -type f -print0)
done

log "Stowing packages…"
cd "$DOTFILES"
stow --restow --target="$HOME" "${PACKAGES[@]}"

log "Done. Next steps:"
echo "  1. Edit ~/.zshrc.local and ~/.gitconfig.local with your personal/work values."
echo "  2. Open a new shell (or 'exec zsh')."
echo "  3. In tmux, press <prefix> + I to install plugins via TPM."
