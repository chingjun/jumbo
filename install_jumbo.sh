#!/bin/bash

echo

set -e
trap 'echo Error on line $BASH_SOURCE:$LINENO' ERR
trap 'rm -f $tmp' EXIT

if [[ -n "$JUMBO_ROOT" && -d "$JUMBO_ROOT" && -f "$JUMBO_ROOT/bin/jumbo" ]]
then
    echo "Jumbo is already installed in your system"
    exit 1
fi

JUMBO_REPO="http://jumbo.ws"
JUMBO_LOCATION="$JUMBO_REPO/jumbo"

DEFAULT_JUMBO_ROOT="$HOME/.jumbo"

if [[ "$1" == "-d" ]]
then
    echo "Where would you want to install jumbo?"
    echo -n "[$DEFAULT_JUMBO_ROOT]: "
    read JUMBO_ROOT
    if [ -z "$JUMBO_ROOT" ]
    then
        JUMBO_ROOT="$DEFAULT_JUMBO_ROOT"
    fi
    if [ "${JUMBO_ROOT:0:1}" != "/" ]
    then
        JUMBO_ROOT="$PWD/$JUMBO_ROOT"
    fi
else
    JUMBO_ROOT="$DEFAULT_JUMBO_ROOT"
fi

mkdir -p "$JUMBO_ROOT"
bash -c "$( curl "$JUMBO_LOCATION" 2>/dev/null )" jumbo -n -r "$JUMBO_ROOT" -p "$JUMBO_REPO" install jumbo
if ! grep "$JUMBO_ROOT/etc/bashrc" "$HOME/.bashrc" 2>/dev/null
then
    echo "[[ -s \"$JUMBO_ROOT/etc/bashrc\" ]] && source \"$JUMBO_ROOT/etc/bashrc\"" >> "$HOME/.bashrc"
fi
