# Initialize zinit
# Point HOME_DIR at a writable location since /usr/share/zinit is system-owned.
typeset -A ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
source /usr/share/zinit/zinit.zsh

# Must load before zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

source ~/.zsh/themes/zsh-syntax-highlighting.zsh
zinit light zsh-users/zsh-syntax-highlighting

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
zinit light zsh-users/zsh-autosuggestions

zinit snippet OMZP::git-auto-fetch

zinit light Aloxaf/fzf-tab
