# ~/.zshrc — interactive shell config
# Managed by github.com/josecolella/dotfiles. Machine-local and work-specific
# settings live in ~/.zshrc.local (gitignored) — see the end of this file.

# --- oh-my-zsh (theme disabled; starship renders the prompt) ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
source "$ZSH/oh-my-zsh.sh"

# --- zplug (async support for a snappy prompt) ---
export ZPLUG_HOME="$(brew --prefix)/opt/zplug"
source "$ZPLUG_HOME/init.zsh"
zplug "mafredri/zsh-async", from:github
zplug check || zplug install
zplug load

# --- prompt ---
eval "$(starship init zsh)"

# --- fuzzy finder ---
source <(fzf --zsh)

# --- sqlite-backed shell history (zsh-histdb) ---
autoload -Uz add-zsh-hook
source "$HOME/.oh-my-zsh/custom/plugins/zsh-histdb/sqlite-history.zsh"

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"

# --- bun ---
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# --- worktree helper (wt) ---
if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

# --- machine-local & work config (not tracked in this repo) ---
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
