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

if [ -z $TMUX_POWERLINE_LEFT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		"tmux_session_info 235 136" \
		"hostname 235 136" \
		#"ifstat 235 136" \
		#"ifstat_sys 235 136" \
		"lan_ip 235 136 ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}" \
		"wan_ip 235 136" \
		"vcs_branch 235 136" \
		"vcs_compare 235 136" \
		"vcs_staged 235 136" \
		"vcs_modified 235 136" \
		"vcs_others 235 136" \
	)
fi

if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		#"earthquake 235 136" \
		#"pwd 235 136" \
		#"mailcount 235 136" \
		#"now_playing 235 136" \
		#"cpu 235 136" \
		"load 235 136" \
		#"tmux_mem_cpu_load 235 136" \
		"battery 235 136" \
		#"weather 235 136" \
		#"rainbarf 235 136" \
		#"xkb_layout 235 136" \
		"date_day 235 136" \
		"date 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
		"time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
		#"utc_time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
	)
fi
