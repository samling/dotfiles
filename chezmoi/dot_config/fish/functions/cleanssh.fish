function cleanssh --description 'kill ssh-agent and unset its env vars'
    pkill ssh-agent
    set -e SSH_AGENT_PID
    if set -q SSH_AUTH_SOCK
        rm -f -- $SSH_AUTH_SOCK
        set -e SSH_AUTH_SOCK
    end
    rm -f $HOME/.config/ssh-agent.pid
end
