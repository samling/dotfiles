function battery {
    battery.sh
}

function charge {
    charge.sh
}

function batterycharge {
    batterycharge.sh
}

#PROMPT='%{$bg[black]%}%{$fg[green]%}%~%{$fg_bold[blue]%}$(git_prompt_info)%  →'
#PROMPT='%{$fg[red]%}$(battery.sh)%{$fg[yellow]%} %n %{$fg[green]%}%~%{$fg[white]%} '
PROMPT=' %{$fg[green]%}%~%{$fg[white]%} '


# Right-side prompt
#RPROMPT='%{$fg[red]%}$(battery.sh)% %{$fg[white]%}'
#RPROMPT='%{$fg[yellow]%}%T%{$fg[red]%} $(battery.sh)% %{$fg[white]%}'

# Show battery and charging info in RPROMPT
#RPROMPT='%{$fg[yellow]%}%T%{$fg[red]%}【$(batterycharge.sh)% 】%{$fg[white]%}'

# In case above RPROMPT stops working
#RPROMPT='%{$fg[yellow]%}%T%{$fg[red]%}【$(battery.sh)$(charge.sh)% 】%{$fg[white]%}'


ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_DIRTY=" ✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" ✔"
