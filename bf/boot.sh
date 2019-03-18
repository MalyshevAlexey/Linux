#!/bin/bash

BF::SourceFile() {
    local libPath="$1"
    shift
    [[ ! -f "$libPath" ]] && return 1
    builtin source "$libPath" "$@" || return 1
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
        BF::SourceFile "$libPath" "$@" && return 0 || BF::SourceFile "${libPath}.sh" "$@" && return 0
    fi
    return 1
}

BF::ImportOne() {
    for i in "${!BF_IMPORT_ALGO[@]}"; do ${BF_IMPORT_ALGO[$i]} "$@" && return 0; done
    throw "Unable to load $1"
}

BF::Import() {
    local libPath
    for libPath in "$@"
    do
        BF::ImportOne "$libPath"
    done
}

BF::DumpStack() {
    local divider==============================================
    local width=45
    local format=" %-3s %-20s %s\n"
    printf "\n${format}" "N" "FUNCTION" "SCRIPT SOURCE"
    printf "%$width.${width}s\n" "$divider"
    for ((i=1; i < "${#BASH_SOURCE[@]}"; i++)) do printf "${format}" $((i-1)) "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}"; done    
    echo
}

BF::DefaultImport() {
    [[ $# < 1 ]] && return 1
    local libs=($(printf "%q\n" "${BASH_SOURCE[@]}" | sort -u))
    for path in "${libs[@]}"
    do 
        BF::SourcePath $([[ $path =~ ^\..*|^/.* ]] && cd "${path%/*}" || cd . && pwd)/$1 "$@" && return 0
    done
    false
}

BF::Boot() {
:
}

export PS4='+(${BASH_SOURCE##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -o pipefail
shopt -s expand_aliases
declare -g ALEXX="alexx"
declare -ag BF_IMPORT_ALGO
declare -ag BF_IMPORTED_FILES

BF_IMPORT_ALGO+=(BF::DefaultImport)

namespace() { :; }
throw() { eval 'cat <<< "Exception: $e ($*)" 1>&2; read -s;'; }

BF::Boot

alias import="BF::Import"
alias source="BF::ImportOne"
alias .=source

declare -g BF_BOOTED=true
