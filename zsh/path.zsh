# Set Android SDK home
ANDROID_HOME=$HOME/Documents/Android-SDK

# Using Homebrew without Linux CoreUtils
PATH=$PATH:/usr/local:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
# Java applet plugin
PATH=/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin:$PATH
# Golang
PATH=$PATH:/usr/local/go/bin
# Go Home
PATH=$PATH:$HOME/.gocode
# RVM
PATH=$PATH:$HOME/.rvm/bin:/usr/local/rvm/bin:$HOME/.rbenv/bin:$HOME/.rbenv/shims
# X11
PATH=$PATH:/opt/X11/bin
# Munki
PATH=$PATH:/usr/local/munki
# Android SDK
PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
# Final path export
export PATH



# Old path stuff
# export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/Users/sboynton/.local.bin:/opt/X11/bin:/usr/local/munki:/Users/s
