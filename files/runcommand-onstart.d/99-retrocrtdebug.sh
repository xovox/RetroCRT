#!/bin/bash

OADB=$HOME/OpenArcadeDB

# use git@github.com:xovox/OpenArcadeDB.git
if [ -d $OADB ]; then
    grep -ris . "$OADB/games/$ra_rom_basename/" | cut -d'/' -f6- | column -s: -t
fi
