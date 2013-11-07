function precmd {
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))
}

function collapse_pwd {
    echo $(pwd | sed -e "s,^$HOME,~,")
}

function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '•' && return
    echo '•'
}

PROMPT='[%{$fg[green]%}%n %{$reset_color%}on %{$fg[red]%}%m %{$reset_color%}in %{$fg_bold[blue]%}$(collapse_pwd)%{$reset_color%}$(git_prompt_info)]
%{$reset_color%} ≫ '

RPROMPT=''

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✘"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔"
