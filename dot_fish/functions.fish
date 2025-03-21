# Git status of subdirectories
function git-status
    find . -type d -name '.git' | while read dir
        pushd (dirname $dir)
        git status -s | grep -q '[azAZ09]' && echo "\n\033[1m [ $dir ]\n\033[m" && git status -s
        popd
    end
end

# Recent git branches
function git-recent
    set branch (for i in (seq 1 10)
        echo "$i. "(git rev-parse --symbolic-full-name "@{-$i}" 2>/dev/null)
    end | fzf | cut -d'.' -f2 | sed 's/refs\/heads\///g' | string trim)
    [ -n "$branch" ] && git checkout $branch
end

# Unset AWS variables
function unset-aws
    echo "Unsetting AWS_* variables"
    for var in (set -n | grep '^AWS')
        echo "Unsetting $var"
        set -e $var
    end
end

# Man pages with fzf
function fman
    man -k . | fzf --exact -q "$argv" --prompt='man> ' --preview 'echo {} | tr -d "()" | awk "{printf \"%s \", \$2} {print \$1}" | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | read -l cmd
    if test $status = 0
        man $cmd
    end
end

# JWT decode
function jwtdecode
    if type -q jq
        echo $argv[1] | jq -R 'split(".") | .[0],.[1] | @base64d | fromjson'
        echo "Signature: "(echo $argv[1] | awk -F'.' '{print $3}')
    end
end

# Nvim with profiling
function nvim-maybe-profile
    if test "$NVIM_PROFILE" = "true"
        echo "[DEBUG] Logging nvim startup profile to /tmp/nvim-profile.log"
        echo '[DEBUG] Run `set -e NVIM_PROFILE` to disable'
        if test -f /tmp/nvim-profile.log
            echo "[DEBUG] Previous log file found; removing it"
            rm -f /tmp/nvim-profile.log >/dev/null 2>&1
        end

        nvim --startuptime /tmp/nvim-profile.log $argv

        if test $status -eq 0
            echo "[DEBUG] Log file saved to /tmp/nvim-profile.log"
            if test -f /tmp/nvim-profile.log; and test "$NVIM_PROFILE_SAVE_ON_EXIT" != "true"
                echo '[DEBUG] Set `set -gx NVIM_PROFILE_SAVE_ON_EXIT true` to save the file instead'
                echo ""
                cat /tmp/nvim-profile.log
                echo ""
                echo '[DEBUG] Removing temporary log file'
                rm -f /tmp/nvim-profile.log >/dev/null 2>&1
            else
                echo '[DEBUG] Log file saved to /tmp/nvim-profile.log'
            end
        end
    else
        nvim $argv
    end
end 