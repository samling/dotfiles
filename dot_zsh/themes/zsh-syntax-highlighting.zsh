# zsh-syntax-highlighting theme using ANSI color indices
# Uses ANSI color indices for terminal palette compatibility
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
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=1,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=1,underline'

# Default/neutral — inherit terminal foreground
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='none'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='none'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[assign]='none'
ZSH_HIGHLIGHT_STYLES[named-fd]='none'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='none'
ZSH_HIGHLIGHT_STYLES[redirection]='none'
ZSH_HIGHLIGHT_STYLES[globbing]='none'
ZSH_HIGHLIGHT_STYLES[arg0]='none'
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[cursor]='none'
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'
