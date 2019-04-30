CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/variables.sh"

main() {
	tmux display-message -p "test message"
	tmux bind-key "$default_save_key" run-shell "$CURRENT_DIR/scripts/save.sh"
}

main