# Default Theme

if patched_font_in_use; then
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="⮂"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="⮃"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="⮀"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="⮁"
else
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-'235'}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'136'}

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}


# Format: segment_name background_color foreground_color [non_default_separator]

# ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}
if [ -z $TMUX_POWERLINE_LEFT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
    "tmux_session_info 232 214 " \
		"hostname 234 214 " \
		#"ifstat 235 214" \
		#"ifstat_sys 235 214" \
		"lan_ip 236 214 " \
		"wan_ip 238 214 " \
		"vcs_branch 235 214" \
		"vcs_compare 235 214" \
		"vcs_staged 235 214" \
		"vcs_modified 235 214" \
		"vcs_others 235 214" \
	)
fi

# ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}
if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		#"earthquake 235 214" \
		#"pwd 235 214" \
		#"mailcount 235 214" \
		#"now_playing 235 214" \
		#"cpu 235 214" \
		"load 238 214" \
		#"tmux_mem_cpu_load 235 214" \
		#"battery 235 214" \
		#"weather 235 214" \
		#"rainbarf 235 214" \
		#"xkb_layout 235 214" \
		"date_day 236 214" \
		"date 234 214 " \
		"time 232 214 " \
		#"utc_time 235 214 " \
	)
fi
