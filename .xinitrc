# Setting additional font paths
xset +fp /usr/share/fonts/local
xset fp rehash

# Setting cursor style
xsetroot -cursor_name left_ptr

# Setting the displays
xrandr --output DP-1 --off --output HDMI-0 --mode 1920x1080 --pos 64x0 --rotate normal --output DVI-I-2 --off --output DVI-I-1 --off --output DVI-I-0 --off --output DVI-I-3 --mode 2048x1152 --pos 0x1080 --rotate normal --output DP-0 --off

# Setting the wallpaper
feh --bg-scale ~/Pictures/8X2cWV3.jpg

# Session handlers
DEFAULT_SESSION=xmonad
case $1 in
xmonad)
exec dbus-launch xmonad
;;
awesome)
exec dbus-launch awesome
;;
openbox-session)
exec dbus-launch openbox-session
;;
fluxbox)
exec startfluxbox
;;
*)
exec dbus-launch $DEFAULT_SESSION
esac
