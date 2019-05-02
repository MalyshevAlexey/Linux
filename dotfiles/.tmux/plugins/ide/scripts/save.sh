delimiter=$'\t'

session_format() {
	local format
	format+="session"
	format+="${delimiter}"
	format+="#{session_name}"
	format+="${delimiter}"
	format+="#{session_windows}"
	echo "$format"
}

window_format() {
	local format
	format+="window"
	format+="${delimiter}"
	format+="#{session_name}"
	format+="${delimiter}"
	format+="#{window_index}"
	format+="${delimiter}"
	format+=":#{window_name}"
	format+="${delimiter}"
	format+="#{window_active}"
	format+="${delimiter}"
	format+="#{window_panes}"
	format+="${delimiter}"
	format+=":#{window_flags}"
	format+="${delimiter}"
	format+="#{window_layout}"
	echo "$format"
}

pane_format() {
	local format
	format+="pane"
	format+="${delimiter}"
	format+="#{session_name}"
	format+="${delimiter}"
	format+="#{window_index}"
	format+="${delimiter}"
	format+="#{pane_index}"
	format+="${delimiter}"
	format+=":#{pane_current_path}"
	format+="${delimiter}"
	format+="#{pane_active}"
	format+="${delimiter}"
	format+="#{pane_current_command}"
	format+="${delimiter}"
	format+="#{pane_pid}"
	format+="${delimiter}"
	format+="#{history_size}"
	echo "$format"
}

state_format() {
	local format
	format+="state"
	format+="${delimiter}"
	format+="#{client_session}"
	format+="${delimiter}"
	format+="#{client_last_session}"
	echo "$format"
}

dump_sessions() {
	tmux list-sessions -F "$(session_format)"
}

dump_windows() {
	tmux list-windows -a -F "$(window_format)"
}

dump_panes() {
	tmux list-panes -a -F "$(pane_format)"
}

dump_state() {
	tmux display-message -p "$(state_format)"
}

save_all() {
	#dump_sessions > "$HOME/.tmux/sessions.bak"
	dump_windows > "$HOME/.tmux/sessions.bak"
	dump_panes >> "$HOME/.tmux/sessions.bak"
	dump_state >> "$HOME/.tmux/sessions.bak"
}

save_all
tmux display "save.sh $HOME/.tmux/sessions.bak"
