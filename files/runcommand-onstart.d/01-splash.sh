#!/bin/bash

eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"

framebuffer=/dev/fb0
rom_image_dir="$HOME/RetroPie/roms/$ra_system/images"

# splash screens, from most desierable to least
rom_splash_screens="
$rom_image_dir/$ra_rom_basename-splash.png
$rom_image_dir/$ra_rom_basename-splash.jpg
$rom_image_dir/$ra_rom_basename-image.png
$rom_image_dir/$ra_rom_basename-image.jpg
$rom_image_dir/default-splash.png
$rom_image_dir/default-splash.jpg
$HOME/RetroPie/splashscreens/loading.png
$HOME/RetroPie/splashscreens/loading.jpg
"

echo "$rom_splash_screens" | while read rom_splash_screen ; do
#for rom_splash_screen in $rom_splash_screens ; do
    if [[ -f "$rom_splash_screen" ]]; then
        #fbi --autozoom --noverbose --timeout 2 --once -T 1 --device $framebuffer "$rom_splash_screen"
        fbi --autozoom --noverbose --timeout 2 --once --device $framebuffer -T 0 "$rom_splash_screen"
	#fbi", "-a", "-noverbose", "-norandom", "-T 1", "-t 8
        break
    fi
done
