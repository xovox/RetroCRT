#!/bin/bash

eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"

if [ "$retrocrt_hardware" = "pi4" ]; then
	exit 0
fi

export rom_timings="$retrocrt_timings/default"
retrocrt_timings
