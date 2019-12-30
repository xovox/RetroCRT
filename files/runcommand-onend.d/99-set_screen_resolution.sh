#!/bin/bash

eval "$(dos2unix < "/boot/retrocrt.txt")"

export rom_timings="$retrocrt_timings/default"
retrocrt_timings
