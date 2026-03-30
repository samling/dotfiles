# zsh-syntax-highlighting theme using ANSI color indices
# Works with both static (catppuccin) and dynamic (pywal) terminal palettes
# Key distinction: valid commands = green, unknown/errors = red

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES

# Valid commands — green (ANSI 2), clearly distinct from errors
ZSH_HIGHLIGHT_STYLES[command]='fg=2'
ZSH_HIGHLIGHT_STYLES[alias]='fg=2'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=2'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=2'
ZSH_HIGHLIGHT_STYLES[function]='fg=2'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=2'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=2'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=2'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=2,italic'

# Errors / unknown — red (ANSI 1)
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=1'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=1'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=1'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=1'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=1'

# Strings — yellow (ANSI 3)
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=3'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=3'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=3'
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=3'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=3'

# Options — cyan (ANSI 6)
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=6'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=6'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=6,italic'

# Substitutions/expansions — magenta (ANSI 5)
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=5'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=5'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=5'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=5'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=5'

# Delimiters/separators — red (ANSI 1)
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=1'

# Paths — foreground with underline
ZSH_HIGHLIGHT_STYLES[path]='fg=7,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=1,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=7,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=1,underline'

# Default/neutral — foreground (ANSI 7)
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=7'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=7'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=7'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=7'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=7'
ZSH_HIGHLIGHT_STYLES[assign]='fg=7'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=7'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=7'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=7'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=7'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=7'
ZSH_HIGHLIGHT_STYLES[default]='fg=7'
ZSH_HIGHLIGHT_STYLES[cursor]='fg=7'
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'
