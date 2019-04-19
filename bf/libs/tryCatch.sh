[[ "$BF_BOOTED" = true ]] || exit 1

set -E
declare -ig order=0
declare -ig BF_TRYCATCH_LEVEL=0
declare -g BF_ERROR_STR=""

trap "Exception::Error" ERR
trap "Exception::Terminate" TERM

alias try='BF_TRYCATCH_LEVEL+=1; for _ in 1; do '
alias catch='done 2> >(Exception::Parse); Exception::Check || '

Exception::Error() {
    BF_ERROR=$?
	echo "capture $BF_ERROR $BASH_COMMAND $- ${BASH_LINENO[@]} $?"
	BF::DumpStack "$BASH_COMMAND"
    break
}

Exception::Terminate() {
    exit $BF_ERROR
}

Exception::Check() {
	local retVal=$BF_ERROR
    echo "level $BF_TRYCATCH_LEVEL, error $BF_ERROR, set $-"
    BF_TRYCATCH_LEVEL+=-1
    BF_ERROR=0
    BF_ERROR_STR=""
    return $retVal
}

Exception::Parse() {
    local count=0;
    while read -r line
    do
        BF_ERROR_STR+="$line\n"
        count=$((count+1))
    done
    BF_ERROR_STR=$(echo -e "$BF_ERROR_STR" | sed '$d')
    if (( $count > 0 )); then echo "$BF_ERROR_STR"; fi;
}

Exception::Analize() {
:
}
