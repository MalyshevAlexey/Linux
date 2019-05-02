d=$'\t'

session_exists() {
	local session_name="$1"
	tmux has-session -t "$session_name" 2>/dev/null
}

create_new_session() {
	local session_name="$1"
	TMUX="" tmux new-session -d -s "$session_name"
}

create_new_window() {
	local session_name="$1"
	local window_number="$2"
	local window_name="$3"
	local dir="$4"
	TMUX="" tmux new-window -d -t "${session_name}:${window_number}" -n "$window_name" -c "$dir"
}

create_new_pane() {
	local session_name="$1"
	local window_number="$2"
	local window_name="$3"
	local dir="$4"
	local pane_index="$5"
	local pane_id="${session_name}:${window_number}.${pane_index}"
	tmux split-window -t "${session_name}:${window_number}" -c "$dir"
	tmux resize-pane -t "${session_name}:${window_number}" -U "999"
}

restore_windows() {
	local session=
	grep '^window' "$HOME/.tmux/sessions.bak" | 
	while IFS=$d read line_type session_name window_index window_name window_active window_panes window_flags window_layout
	do
		if [ "$sessoin" != "$session_name" ]; then
			session_exists "$session_name" || create_new_session "$session_name"
			sessoin=$session_name
		fi
		TMUX="" tmux new-window -d -t "${session_name}:${window_index}" -n "$window_name"
		for (( c=1; c<window_panes; c++ ))
		do  
			 tmux split-window -t "${session_name}:${window_index}"
		done
		tmux select-layout -t "${session_name}:${window_index}" "$window_layout" >/dev/null 2>&1
	done
}

restore_panes() {
	grep '^pane' "$HOME/.tmux/sessions.bak" | 
	while IFS=$d read line_type session_name window_index pane_index pane_current_path pane_active pane_current_command
	do
		tmux respawn-pane -k -t "${session_name}:${window_index}.${pane_index}"
	done
}

restore_state() {
	grep '^state' "$HOME/.tmux/sessions.bak" | 
	while IFS=$d read line_type client_session client_last_session
	do
		tmux switch-client -t "$client_last_session"
		tmux switch-client -t "$client_session"
	done
}

restore_all() {
	restore_windows
	restore_panes
	restore_state
}

restore_all_bak() {
	while read one two three four five six seven eight nine
	do
		local window=${one::-1}
		local panes=${three:1}
		local layout=${seven::-1}
		tmux display "${one::-1} ${three:1} ${seven::-1}"
		tmux new-window -t $window
		for (( c=1; c<panes; c++ ))
		do  
			 tmux split-window -h
		done
		tmux select-layout -t $window $layout >/dev/null 2>&1
	done < "$HOME/.tmux/sessions.bak"
}

restore_all
