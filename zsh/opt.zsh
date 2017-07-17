# ======== HISTORY

setopt AUTO_CD                  # Typing a directory and hitting enter will go to that directory
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shells
setopt NO_BEEP                  # No beep on error
HISTFILE=$HOME/.zhistory        # Make a history file
HISTSIZE=2000                   # Save 2000 bytes of command history
SAVEHIST=2000                   # Maximum commands to save
setopt SHARE_HISTORY            # Share history between zsh sessions
setopt INC_APPEND_HISTORY       # Append lines to history as soon as they're entered, rather than when the shell exits
setopt HIST_IGNORE_DUPS         # Do not write events to history that are duplicates of previous events
setopt HIST_FIND_NO_DUPS        # When searching history don't display results already cycled through twice
setopt HIST_REDUCE_BLANKS       # Remove extra blanks from each command line being added to history
setopt HIST_IGNORE_SPACE        # Remove from history if first line is a space
setopt EXTENDED_HISTORY         # Include more information about when the command was executed, etc.
setopt HIST_VERIFY              # Don't execute, just expand history

# ======== COMPLETION

setopt EXTENDED_GLOB            # Activate complex pattern globbing; required to change CASE_GLOB
setopt COMPLETE_IN_WORD         # Allow completing from within a word/phrase
setopt ALWAYS_TO_END            # When completing from the middle of a word, move cursor to the end of the word
unsetopt MENU_COMPLETE          # do not autoselect the first completion entry
setopt AUTO_MENU                # Show completion menu on successive tab press; needs unsetopt menu_complete to work
setopt LIST_AMBIGUOUS           # Complete as much as possible until ambiguous
unsetopt CORRECT                # Disable autocorrection
unsetopt CASE_GLOB              # Turn off case-sensitive globbing
setopt NONOMATCH                # Disable "no match found" behavior to be more like bash in cases of failed expansion

# ======== PUSHD

setopt AUTO_PUSHD               # Make cd push old dir in dir stack
setopt PUSHD_IGNORE_DUPS        # No duplicates in dir stack
setopt PUSHD_SILENT             # No dir stack after pushd or popd
setopt PUSHD_TO_HOME            # `pushd` = `pushd $HOME`

# ======== PROMPT

autoload -U colors && colors    # Allow colors in prompt
setopt PROMPT_SUBST             # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt

# ======== GLOBBING

setopt AUTO_REMOVE_SLASH        # Removes slashes
setopt CHASE_LINKS              # Resolve symlinks
setopt GLOB_DOTS                # Include dotfiles in globbing
unsetopt CASE_GLOB		        # Turn off case-sensitive globbing

# ======== VI MODE

zle -N zle-line-init
zle -N zle-keymap-select

# ======== TERMINAL BEHAVIOR

setopt IGNORE_EOF               # Prevent ZSH from quitting with ctrl-d

# ======== ZSTYLES

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive tab completion
#zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive tab completion only if there are no case-sensitive matches
