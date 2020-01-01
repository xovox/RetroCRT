#!/bin/bash

# Use https://github.com/xovox/OpenArcadeDB/raw/master/OpenArcadeDB_Linux.tar.bz2
OADB=$HOME/OpenArcadeDB_Linux.tar.bz2

if [ -d $OADB ]; then
	bzgrep2 "^$ra_rom_basename/" $OADB
#    grep -ris . "$OADB/games/$ra_rom_basename/" | cut -d'/' -f6- | column -s: -t | sort
fi
