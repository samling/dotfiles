# Set Android SDK home
ANDROID_HOME=$HOME/Library/Android/sdk
# Golang
PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# Using Homebrew without Linux CoreUtils
PATH=$PATH:/usr/local:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
# Java applet plugin
#PATH=/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin:$PATH
# pip & python
PATH=/usr/local/opt/python/libexec/bin:$PATH
PATH=$PATH:/Users/sboynton/Library/Python/3.6/bin
PATH=$PATH:/Users/sboynton/Library/Python/3.7/bin
# RVM
PATH=$PATH:$HOME/.rvm/bin:/usr/local/rvm/bin:$HOME/.rbenv/bin:$HOME/.rbenv/shims
# X11
PATH=$PATH:/opt/X11/bin
# Mono
PATH=$PATH:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/Library/Frameworks/Mono.framework/Versions/Current/bin
# Munki
PATH=$PATH:/usr/local/munki
# Android SDK
PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
# Final path export
export PATH



# Old path stuff
# export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/Users/sboynton/.local.bin:/opt/X11/bin:/usr/local/munki:/Users/s
