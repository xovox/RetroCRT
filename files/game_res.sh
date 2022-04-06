#!/bin/bash

exit
vcgencmd hdmi_timings 320 1 20 37 55 240 1 2 3 16 0 0 0 60 0 6400000 1
tvservice -e  "DMT 87" > /dev/null
sleep 0.3
fbset -depth 8 && fbset -depth 24
sleep 0.3
