# Environment
#export TERM=screen-256color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Default editor
export EDITOR="vim"

# Go Code
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/.gocode

# Tmux
export TMUX_POWERLINE_SEG_WEATHER_LOCATION="2411898"

# GCC
export ARCHFLAGS="-arch x86_64"

# Docker
#eval $(docker-machine env default)
#export DOCKER_HOST=tcp://192.168.59.103:2376
#export DOCKER_CERT_PATH=/Users/sboynton/.boot2docker/certs/boot2docker-vm
#export DOCKER_TLS_VERIFY=1

# VI Mode
export KEYTIMEOUT=1

# Python/Pip options
export PIP_REQUIRE_VIRTUALENV=1 # Require a virtualenv before pip will install a package (prevents packages being installed globally)

# Perl
PATH="/Users/sboynton/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/sboynton/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/sboynton/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/sboynton/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/sboynton/perl5"; export PERL_MM_OPT;
