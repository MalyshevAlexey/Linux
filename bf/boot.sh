#!/bin/bash

BF::ContainsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

BF::DumpStack() {
    local divider=============================================
    divider=$divider$divider
    local width=70
    local format=" %-3s %-5s %-20s %s\n"
    printf "\n${format}" "N" "LINE" "FUNCTION" "SCRIPT SOURCE"
    printf "%$width.${width}s\n" "$divider"
    local length="${#BASH_SOURCE[@]}"
    length=$length-1
    for ((i=1; i < length; i++))
    do
        printf "${format}" $((i-1)) "${BASH_LINENO[$i]}" \
        "$([[ $i = 1 ]] && echo $1 || echo ${FUNCNAME[$i]})" \
        "${BASH_SOURCE[$i+1]}"
    done
    echo
}

BF::GetDirname() {
    echo "$( cd "$( dirname "$1" )" >/dev/null 2>&1 && pwd )"
}

BF::SourceFile() {
    local libPath="$1"
    shift
    [[ ! -f "$libPath" ]] && return 1
    BF::ContainsElement "$libPath" "${BF_IMPORTED_FILES[@]}" || \
    builtin source "$libPath" "$@" && BF_IMPORTED_FILES+=("$libPath")
}

BF::SourcePath() {
    local libPath="$1"
    shift
    if [[ -d "$libPath" ]]
    then
        local file
        for file in "$libPath"/*.sh
        do
            BF::SourceFile "$file" "$@" || return 1
        done
        return 0
    else
        { BF::SourceFile "$libPath" "$@" || BF::SourceFile "${libPath}.sh" "$@"; } && return 0
    fi
    return 1
}

BF::SingleImport() {
    local algorithm
    for algorithm in "${BF_IMPORT_ALGO[@]}"
    do
        "$algorithm" "$@" && return 0;
    done
    die "Unable to load $1"
    #return 1
}

BF::Import() {
    local libPath
    for libPath in "$@"
    do
        BF::SingleImport "$libPath"
    done
}

BF::DefaultImport() {
    [[ $# < 1 ]] && return 1
    for path in "${BASH_SOURCE[@]}"; do
        BF::SourcePath $(BF::GetDirname "$path")/$1 "$@" && return 0
    done
    return 1
}

BF::Boot() {
:
}

export PS4='+(${BASH_SOURCE##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -o pipefail
shopt -s expand_aliases
declare -ag BF_IMPORT_ALGO
declare -ag BF_IMPORTED_FILES
declare -g BF_ERROR=0
declare -g TOP_PID=$$

BF_IMPORT_ALGO+=(BF::DefaultImport)

namespace() { :; }
throw() { [[ -n $1 ]] && BF_ERROR=$1 || BF_ERROR=1; break; }
die() { [[ -n $1 ]] && echo "$1"; kill -TERM $TOP_PID; }

BF::Boot

alias import="BF::Import"
alias source="BF::SingleImport"
alias .=source

declare -g BF_BOOTED=true
