# ~/.zprofile — login shell config
# Managed by github.com/josecolella/dotfiles

# Obsidian CLI (only matters if Obsidian is installed)
if [ -d "/Applications/Obsidian.app/Contents/MacOS" ]; then
  export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi
