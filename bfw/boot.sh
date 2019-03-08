#!/bin/bash

BFW::SourceFile() {
    local libPath="$1"
    shift
    [[ ! -f "$libPath" ]] && return 1
    builtin source "$libPath" "$@" || return 1
}

BFW::SourcePath() {
    local libPath="$1"
    shift
    if [[ -d "$libPath" ]]
    then
        local file
        for file in "$libPath"/*.sh
        do
            BFW::SourceFile "$file" "$@" || return 1
        done
        return 0
    else
        BFW::SourceFile "$libPath" "$@" && return 0 || BFW::SourceFile "${libPath}.sh" "$@" && return 0
    fi
    return 1
}

BFW::ImportOne() {
    for i in "${!BFW_IMPORT_ALGO[@]}"; do ${BFW_IMPORT_ALGO[$i]} "$@" && return 0; done
    throw "Unable to load $1"
}

BFW::Import() {
    local libPath
    for libPath in "$@"
    do
        BFW::ImportOne "$libPath"
    done
}

BFW::DumpStack() {
    local divider==============================================
    local width=45
    local format=" %-3s %-20s %s\n"
    printf "\n${format}" "N" "FUNCTION" "SCRIPT SOURCE"
    printf "%$width.${width}s\n" "$divider"
    for ((i=1; i < "${#BASH_SOURCE[@]}"; i++)) do printf "${format}" $((i-1)) "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}"; done    
    echo
}

BFW::DefaultImport() {
    [[ $# < 1 ]] && return 1
    local libs=($(printf "%q\n" "${BASH_SOURCE[@]}" | sort -u))
    for path in "${libs[@]}"
    do 
        BFW::SourcePath $([[ $path =~ ^\..*|^/.* ]] && cd "${path%/*}" || cd . && pwd)/$1 "$@" && return 0
    done
    false
}

BFW::Boot() {
:
}

export PS4='+(${BASH_SOURCE##*/}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -o pipefail
shopt -s expand_aliases
declare -g ALEXX="alexx"
declare -ag BFW_IMPORT_ALGO
declare -ag BFW_IMPORTED_FILES

BFW_IMPORT_ALGO+=(BFW::DefaultImport)

namespace() { :; }
throw() { eval 'cat <<< "Exception: $e ($*)" 1>&2; read -s;'; }

BFW::Boot

alias import="BFW::Import"
alias source="BFW::ImportOne"
alias .=source

declare -g BFW_BOOTED=true
