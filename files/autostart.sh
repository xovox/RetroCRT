#!/bin/bash

wpa_rcrt=/boot/retrocrt/wpa_supplicant.conf
wpa_conf=/etc/wpa_supplicant/wpa_supplicant.conf

eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"

if [[ "$rotate_es" == [13] ]]; then
	resolution_es="240 320"
else
	resolution_es="320 240"
fi

emulationstation --no-splash --screenrotate $rotate_es --resolution $resolution_es #auto
