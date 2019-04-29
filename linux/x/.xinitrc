xsetroot -cursor_name left_ptr
xrdb -merge ~/.Xresources
xmodmap ~/.Xmodmap

sxhkd &
exec bspwm
