# Note: zsh-syntax-highlighting *must* be first, or at least before autosuggestions and zsh-history-substring-search, otherwise there's some funky recursion going on
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Note: Seems like zsh-history-substring-search needs to at least come before autosuggestions
source ~/.zsh/plugins/zsh-history-substring-search.zsh

# Disabling as this seems to cause some weird issues
source ~/.zsh/plugins/zsh-autosuggestions.zsh

# Enable git auto fetch
source ~/.zsh/plugins/git-auto-fetch.plugin.zsh
