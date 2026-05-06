#
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$PATH:$HOME/.local/share/fnm"
  eval "`fnm env`"
fi

# Configuration for FNM node package manager
#
eval "$(fnm env --use-on-cd --shell zsh)"
