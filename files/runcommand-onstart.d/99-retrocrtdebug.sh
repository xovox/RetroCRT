#!/bin/bash

OADB=$HOME/OpenArcadeDB

if [ -d $OADB ]; then
    grep . $OADB/games/$ra_rom_basename/* | cut -d'/' -f6- | column -s: -t
fi
