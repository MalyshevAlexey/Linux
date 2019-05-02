d=$'\t'

session_exists() {
	local session_name="$1"
	tmux has-session -t "$session_name" 2>/dev/null
}

create_new_session() {
	local session_name="$1"
	tmux new-session -d -s "$session_name"
}

create_new_window() {
	local session_name="$1"
	local window_number="$2"
	local window_name="$3"
	local dir="$4"
	tmux new-window -d -t "${session_name}:${window_number}" -n "$window_name" -c "$dir"
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
	grep '^window' "$HOME/.tmux/sessions.bak" | 
	while IFS=$d read line_type session_name window_number window_active window_flags window_layout
	do
		tmux select-layout -t "${session_name}:${window_number}" "$window_layout"
	done
}

restore_panes() {
	local session=
	local window=
	local pane=0
	grep '^pane' "$HOME/.tmux/sessions.bak" | 
	while IFS=$d read line_type session_name window_number window_name window_active window_flags pane_index dir pane_active pane_command pane_full_command
	do
		if [ "$sessoin" != "$session_name" ]; then
			session_exists "$session_name" || create_new_session "$session_name"
			sessoin=$session_name
			window=
		fi
		if [ "$window" != "window_number" ] ; then
			create_new_window "$session_name" "$window_number" "$window_name" "$dir"
			window=$window_number
			pane=0
		fi
		if [[ $pane > 0 ]]; then
			create_new_pane "$session_name" "$window_number" "$window_name" "$dir" "$pane_index"
			(($pane+=1))
		fi
	done
}

restore_all() {
	restore_panes
	#restore_windows
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
