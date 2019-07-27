#!/bin/bash

source $HOME/.retrocrtrc

rom_settings="$(egrep "^$ra_rom_basename," $retrocrt_install/retrocrt_resolutions.csv)"

if [[ "$rom_settings" ]]; then
    rom_vertical_resolution="$(cut -d',' -f3 <<< "$rom_settings")"
    if [[ -f "$retrocrt_timings/1920_$rom_vertical_resolution" ]]; then
        export rom_timings="$retrocrt_timings/1920_$rom_vertical_resolution"
    fi
fi

retrocrt_timings
