dump_windows() {
	tmux list-windows
}

save_all() {
	dump_windows > "$HOME/.tmux/sessions.bak"
}

save_all
tmux display "save.sh $HOME/.tmux/sessions.bak"
