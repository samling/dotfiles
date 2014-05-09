### LS_COLORS
#
# Matrix
# export LSCOLORS=Cafacadagaeaeaabagacad
# Molokai
if [ -f ~/.dircolors ]; then
    eval `gdircolors -b ~/.dircolors`
else
    export LSCOLORS='ExFxCxDxBxegedabagacad'
fi
# Template
# export LSCOLORS='xxxxxxxxxxxxxxxxxxxxxx'
#
# From the man pages:
#
# Default: exfxcxdxbxegedabagacad
#
# a     black
# b     red
# c     green
# d     brown
# e     blue
# f     magenta
# g     cyan
# h     light grey
# A     bold black, usually shows up as dark grey
# B     bold red
# C     bold green
# D     bold brown, usually shows up as yellow
# E     bold blue
# F     bold magenta
# G     bold cyan
# H     bold light grey; looks like bright white
# x     default foreground or background
#
# 1.   directory
# 2.   symbolic link
# 3.   socket
# 4.   pipe
# 5.   executable
# 6.   block special
# 7.   character special
# 8.   executable with setuid bit set
# 9.   executable with setgid bit set
