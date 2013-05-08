#####
##### Custom Aliases
#####

### When using Janus (i.e. swap .vimrc and .vimrc.janus, .vim/ and .vim.janus/):
### See .vimrc.before and .vimrc.after (if they exist) for additional
### configuration. The default 'leader' key is '\' but has been remapped
### to ',' in .vimrc.before.


###
### Sources
###

source ~/dotfiles/functions.zsh

#export SUDO_PS1="\[\h:\w\] \u\\$ "

###
### Open this file and select zsh customizations
###
alias custom='vi ~/dotfiles/custom.zsh'
# The below functions already exist; use "function" (with quotes) to use original
alias functions='vi ~/dotfiles/functions.zsh'
#alias aliases='vi ~/.oh-my-zsh/lib/aliases.zsh'

###
### Aliases for useful libs installed through MacPorts
###

alias r='sudo mtr' # MyTraceRoute, combines ping and traceroute

###
### SSH shortcuts
###

alias samsite='ssh root@50.56.174.88'
alias webhost='ssh root@198.61.210.119'
alias susebox='ssh root@166.78.12.186'
alias anait='ssh anaitovsepyan@192.168.1.134'
alias fygenson='ssh samling@128.111.17.27'

###
### Novacoast stuff
###

alias novacoast='less ~/Novacoast.txt'
alias certs='ssh rmsteam@vpn' # Must be on the VPN to do this

###
### Fun stuff
###

alias starwars='traceroute -m 160 216.81.59.173' # Just run it
alias starwars2='telnet towel.blinkenlights.nl'
alias matrix='cmatrix'
alias rickroll='curl https://raw.github.com/keroserene/rickrollrc/master/roll.sh | bash'
alias undeliverable='afplay ~/Dropbox/Music/undeliverable.m4a'

###
### Applications
###
#alias chrome="open -a Google\ Chrome"
alias chrome=chrome
alias gc=chrome
alias gv='/Applications/MacVim.app/Contents/MacOS/Vim -g' # Use MacVim instead of vim
alias calc='bc -l'

###
### Shortcuts
###
alias desktop="cd ~/Desktop"
alias documents="cd ~/Documents"
alias downloads="cd ~/Downloads"
alias torrents="cd ~/Documents/Torrents"
alias dropbox="cd ~/Dropbox"
alias music="cd ~/Music"
alias movies="cd ~/Movies"
alias applications="cd ~/Applications"
alias apps="cd ~/Applications"
alias o="open"
alias oo="open ."
alias finder="open ."
alias kf="killall Finder"
alias calendar="cal"
alias top="sudo htop"
alias img="quick-look"

###
### Redefining existing functions
###
alias please='sudo'
alias fucking='sudo'
alias rm='rm -i' # Prevent clobbering
alias cp='cp -i' # Prevent clobbering
alias mv='mv -i' # Prevent clobbering
alias which='type -a'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
# MacPorts VIM
#alias vim="/opt/local/bin/vim"
#alias vi="/opt/local/bin/vim"
#":setglobal number" will set line numbers on or off globally
alias vi=/usr/local/bin/vim
alias vim=/usr/local/bin/vim
alias mount="mount | column -t"
alias fg="fg %$1"
alias bg="bg %$1"
alias cfd='cdf'
alias cwd='pwd'

###
### Directory changing
###

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

###
### The 'ls' family
###
# Add colors for filetype and human-readable sizes by default on 'ls'
alias l="ls -G" # Full list of files including hidden files; folders highlighted in yellow have permissions of 777; files listed in bold red text have X permissions on any role (i.e. 755, 777, etc.), which generally indicates a filetype outside a text or image file

###
### The ubiquitous 'll': directories first, with alphanumeric sorting
###
alias ll="ls -aG"
alias lll="ls -alhiG"
alias llll="ls++ -a"
alias lr="ls -GR"
alias lf="ls *(.)"
alias lsusb="system_profiler SPUSBDataType"
alias recent=recent

###
### Utilities and Information
###
alias t="treelvl"
alias tree='tree -Csuh'	# Alternative to recursive ls
alias ld="ls -l | grep "^d"" # List only directories
alias df="df -kH" # Clean disk info
alias h="history"
alias i="ifconfig"
alias ip=my_ip
alias ii="sipcalc -a en1"
alias iii=iii
alias ipo="dig +short myip.opendns.com @resolver1.opendns.com"
alias wimi="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'" # Clean output of IPs in use
alias p="pbpaste" # Paste from clipboard
alias c="pbcopy" # Copy to clipboard
alias v="clear"
alias num="wc -l" # Counts the number of rows/lines in a file or folder
alias du='du -kh'
alias s="du -sh *" # Shows size of current directory + only files in directory
alias sn="du -s * | sort -nr" # Same as above but sorts by size (without -h)
alias ss="du -ch *" # Shows size of current directory + files & folders in directory + files & folders in subdirectories
alias ssn="du -c * | sort -nr" # Same as above but sorts by size (without -h)
alias ddi="sudo killall -INFO dd" # Shows progress of dd in the window that dd is running in
alias ddp="sudo killall -INFO dd" # See above

###
### Homebrew Stuff
###
alias wget='wget -c' # Ensure wget resumes every time
alias rss="/usr/local/bin/newsbeuter"
alias weather="weather.sh"
alias mp3="ncmpcpp" # Be sure to run the mpd server first
alias y="ps -amcwwwxo \"command %mem %cpu\" | grep -v grep | head -30"
alias vics="cat /usr/local/bin/vi-cheatsheet | less"
alias ping2="sudo mtr"
alias fm="ranger"
alias files="ranger"
alias play="mplayer -vo corevideo $1"
alias web="links"
alias www="links"
alias ytdl="youtube-dl $1"
alias todo="todo.sh"

###
### Hax
###
alias arpforward=arpforward
alias arpscan=arpscan
alias a=arpscan
alias aircrack='aircrack-ng'
alias john='./scripts/john-1.7.9-jumbo-7/run/john'
alias jtr='./scripts/john-1.7.9-jumbo-7/run/john'
alias mitm=mitm
alias mitm2=mitm2
alias mitm2log=mitm2log
alias sslstrip=sslstrip
alias etterconf="sudo vi /usr/local/etc/ettercap/etter.conf"
alias ipfwlist="sudo ipfw -at list"
alias ipf=ipf

###
### Show these aliases --- turns out the command 'alias' accomplishes this
###
#alias aliases="cat ~/.oh-my-zsh/custom/custom.zsh | grep alias | sed 's/alias/'→'/g'"

###
### GUI options
###
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias hidehidden="defaults write com.apple.Finder AppleShowAllFiles -bool false"
alias showhidden="defaults write com.apple.Finder AppleShowAllFiles -bool true"
alias f='find' # Usage: find <directory> -name <filename> | e.g. find / -name readme.txt
alias addspacer="defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'" # Kill dock for this to take effect; run as many times as needed

#####
##### Function aliases
#####

alias gg=google

#####
##### Modify terminal behavior
#####

export HISTCONTROL=ignoreboth # Prevent duplicates in history
export HISTCONTROL=erasedups # Prevent duplicates in history
