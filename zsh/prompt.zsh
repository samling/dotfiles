GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
#GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
#GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
#GIT_PROMPT_PREFIX="%{$fg[white]%}(%{$reset_color%}"
#GIT_PROMPT_SUFFIX="%{$fg[white]%})%{$reset_color%}"
GIT_PROMPT_PREFIX=
GIT_PROMPT_SUFFIX="%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"

function parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

function parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi

}

function git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && local git_base=$(basename `git rev-parse --show-toplevel`) && echo "$GIT_PROMPT_PREFIX%{$fg[blue]%}${git_base}%{$fg[white]%}:%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX $(parse_git_state) "
  [ -z "$git_where" ] && echo ""
}

function ssh_prompt_string() {
  [ -n "$SSH_CONNECTION" ] && echo "%{$fg[green]%}%n%{$fg[white]%}@%{$fg[red]%}%m"
  [ -z "$SSH_CONNECTION" ] && echo "%{$fg[green]%}%n"
}

function precmd {
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))
}

function collapse_pwd {
    echo $(pwd | sed -e "s,^$HOME,~,")
}

function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '-' && return
    echo '-'
}

function history_number {
    echo "%{$fg[red]%}(!%h)"
}

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
    #RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $(git_prompt_string) $EPS1"
    zle reset-prompt
}

# Prompt left and right sides
#
# %b => git branch
# %a => current action (rebase/merge)
#
# %F => color dict: black red green yellow blue magenta cyan white
# %f => reset color
# %~ => current path
# %d => current working directory
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)
#
# Color: $fg[color]
#

#add-zsh-hook precmd vcs_info
#zstyle ':vcs_info:*' check-for-changes true
#zstyle ':vcs_info:*' unstagedstr ' %F{red}●%F{yellow}'
#zstyle ':vcs_info:*' stagedstr ' %F{green}●%F{green}'
#zstyle ':vcs_info:git:*' formats        '[%b%u%c]'
#zstyle ':vcs_info:git:*' actionformats  '[%b|%a%u%c]'
if [[ -n $SSH_CONNECTION ]]; then
    PROMPT=" $(ssh_prompt_string) %F{blue}%(5~|%-1~/…/%3~|%4~)%{$reset_color%}%  %F{white}>%{$reset_color%}%  "
else
    PROMPT=' %F{blue}%(5~|%-1~/…/%3~|%4~)%{$reset_color%}%  %F{white}>%{$reset_color%}%  '
fi
#PROMPT=" %F{blue}░▒▓%{$bg[blue]%}%  %F{black}%(5~|%-1~/…/%3~|%4~) %{$reset_color%}% %F{blue}▓▒░%{$reset_color%}%  "
#PROMPT="%U${(r:$COLUMNS:: :)}%u "$'\n'"%F{blue}░▒▓%{$bg[blue]%}%  %F{black}%~ %{$reset_color%}% %F{blue}▓▒░%{$reset_color%}%  "
