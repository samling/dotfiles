# ======== HISTORY

HISTCONTROL=ignoreboth          # Ignore duplicate lines and lines starting with spaces in the history
HISTFILE=$HOME/.zhistory        # Make a history file
HISTFILESIZE=100000             # Save 10000 bytes of command history
HISTSIZE=100000                 # Save 10000 bytes of command history
SAVEHIST=100000                 # Maximum commands to save
setopt AUTO_CD                  # Typing a directory and hitting enter will go to that directory
setopt INTERACTIVE_COMMENTS     # Allow comments in interactive shells
setopt NO_BEEP                  # No beep on error
setopt SHARE_HISTORY            # Share history between zsh sessions
setopt INC_APPEND_HISTORY       # Append lines to history as soon as they're entered, rather than when the shell exits
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS         # Do not write events to history that are duplicates of previous events
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate.
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate entries in the history file.
setopt HIST_FIND_NO_DUPS        # When searching history don't display results already cycled through twice
setopt HIST_REDUCE_BLANKS       # Remove extra blanks from each command line being added to history
setopt HIST_IGNORE_SPACE        # Remove from history if first line is a space
setopt EXTENDED_HISTORY         # Include more information about when the command was executed, etc.
setopt HIST_VERIFY              # Don't execute, just expand history

# ======== COMPLETION

unsetopt MENU_COMPLETE          # Do not autoselect the first completion entry
unsetopt CORRECT                # Disable autocorrection
unsetopt CASE_GLOB              # Turn off case-sensitive globbing
setopt EXTENDED_GLOB            # Activate complex pattern globbing; required to change CASE_GLOB
setopt COMPLETE_IN_WORD         # Allow completing from within a word/phrase
setopt ALWAYS_TO_END            # When completing from the middle of a word, move cursor to the end of the word
setopt AUTO_MENU                # Show completion menu on successive tab press; needs unsetopt menu_complete to work
setopt LIST_AMBIGUOUS           # Complete as much as possible until ambiguous
setopt NONOMATCH                # Disable "no match found" behavior to be more like bash in cases of failed expansion

# ======== PUSHD

setopt AUTO_PUSHD               # Make cd push old dir in dir stack
setopt PUSHD_IGNORE_DUPS        # No duplicates in dir stack
setopt PUSHD_SILENT             # No dir stack after pushd or popd
setopt PUSHD_TO_HOME            # `pushd` = `pushd $HOME`

# ======== PROMPT

autoload -U colors && colors    # Allow colors in prompt
autoload -Uz add-zsh-hook       # Enable ZSH hooks
autoload -Uz vcs_info           # Enable VCS info
setopt PROMPT_SUBST             # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt

# ======== GLOBBING

unsetopt CASE_GLOB		          # Turn off case-sensitive globbing
setopt AUTO_REMOVE_SLASH        # Removes slashes
setopt CHASE_LINKS              # Resolve symlinks
setopt GLOB_DOTS                # Include dotfiles in globbing

# ======== VI MODE

zle -N zle-line-init
zle -N zle-keymap-select

# ======== TERMINAL BEHAVIOR

setopt IGNORE_EOF               # Prevent ZSH from quitting with ctrl-d

# ======== ZSTYLES

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive tab completion
#zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive tab completion only if there are no case-sensitive matches

# fzf-zsh
zstyle ':fzf-tab:*' fzf-flags \
  --tmux=35%,60% \
  --preview-window=down,15 \
  --bind 'ctrl-/:change-preview-window(down,40|)' \
  --color=label:italic \
  --border-label='[C-/] Change Layout' \
  --border-label-pos=0:bottom


#zstyle ':fzf-tab:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-preview '~/.zsh/scripts/preview_all.sh $realpath'

#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
#
#zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat --color=always -pl sh ${(Q)realpath}'
#
#zstyle ':fzf-tab:complete:vim:*' fzf-preview 'bat --color=always -pl sh ${(Q)realpath}'

zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'

# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# git completions
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
	'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
	'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
	'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
	esac'

#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
#zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
#zstyle ':completion:*' menu no
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
#zstyle ':fzf-tab:*' switch-group '<' '>'
#zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
