bars=$(xdo id -N 'Polybar')
bar=$(echo -e $bars | cut -d' ' -f1)
state=$(xprop -id $bar)

if echo $state | /usr/bin/grep "Normal"; then
    xdo hide -N 'Polybar'
else
    xdo show -N 'Polybar'
fi
