#!/bin/bash

eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"

if ! (grep -wq "$1" $retrocrt_install/retrocrt_timings/no_per_rom_timings.txt); then
    rom_settings="$(egrep "^$ra_rom_basename," $retrocrt_install/retrocrt_resolutions.csv)"
fi

if [[ -f $retrocrt_timings/all ]]; then
    export rom_timings="$retrocrt_timings/all"
elif [[ "$rom_settings" ]]; then
    rom_vertical_resolution="$(cut -d',' -f3 <<< "$rom_settings")"
    if [[ -f "$retrocrt_timings/1920_$rom_vertical_resolution" ]]; then
        export rom_timings="$retrocrt_timings/1920_$rom_vertical_resolution"
    fi
fi

retrocrt_timings
