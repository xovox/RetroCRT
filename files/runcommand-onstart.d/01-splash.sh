#!/bin/bash

source $HOME/.retrocrtrc

framebuffer=/dev/fb0
rom_image_dir="$HOME/RetroPie/roms/$ra_system/images"

# splash screens, from most desierable to least
rom_splash_screens="
$rom_image_dir/$ra_rom_basename-splash.png
$rom_image_dir/$ra_rom_basename-splash.jpg
$rom_image_dir/$ra_rom_basename-image.png
$rom_image_dir/$ra_rom_basename-image.jpg
$rom_image_dir/default.png
$HOME/RetroPie/splashscreens/loading.png
$HOME/RetroPie/splashscreens/loading.jpg
"

for rom_splash_screen in $rom_splash_screens ; do
    if [[ -f "$rom_splash_screen" ]]; then
        fbi --autozoom --noverbose --timeout 2 --once --device $framebuffer "$rom_splash_screen"
        break
    fi
done
