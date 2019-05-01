restore_all() {
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
