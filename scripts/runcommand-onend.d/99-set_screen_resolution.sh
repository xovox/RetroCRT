#!/bin/bash

eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"

export rom_timings="$retrocrt_timings/low_res"
retrocrt_timings
