# Initialize zinit
source ~/.zsh/zinit/zinit.zsh

# Must load before zsh-history-substring-search
source ~/.zsh/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
zinit light zsh-users/zsh-syntax-highlighting

zinit light zsh-users/zsh-history-substring-search

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
zinit light zsh-users/zsh-autosuggestions

zinit snippet OMZP::git-auto-fetch

zinit light Aloxaf/fzf-tab
