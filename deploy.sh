#!/bin/bash
cd /home/debian/ehlo/

git fetch

HEAD=$(git rev-parse HEAD)
UPSTREAMHEAD=$(git rev-parse master@{upstream})

if [ "$HEAD" != "$UPSTREAMHEAD" ]
then
        echo -e "New commits found:\n$(git log master..origin/master)"
        git reset --hard origin/master
        hugo
fi
