#!/bin/bash

set -e

reset=$(tput sgr0)
magenta=$(tput setaf 5)
bold=$(tput bold)

log () {
    now=$(date "+%F %T")
    echo "$bold$magenta[$now]" $@ $reset 1>&2
}

logged () {
    log $@
    $@
}

die () { log $@; exit 1; }

# make sure there are no unsaved changes
# https://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommitted-changes
if [[ `git status --porcelain` ]]; then
    die "Unsaved Changes"
fi

REPOSITORY=wonderfulspam/mdbook-docker-image
GIT_SHA=$(git rev-parse --short HEAD)

logged docker build -t $REPOSITORY:$GIT_SHA -t $REPOSITORY:latest .
logged docker push $REPOSITORY
