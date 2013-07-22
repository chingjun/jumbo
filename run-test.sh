#!/bin/bash
cd "$(dirname $0)"
if [ -z "$1" ]
then
    bash ./roundup.sh tests/*-test.sh
else
    bash ./roundup.sh "$@"
fi
