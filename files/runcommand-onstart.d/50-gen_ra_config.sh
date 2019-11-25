#!/bin/bash -x

##############################################################################
# This file is part of RetroCRT (https://github.com/xovox/RetroCRT)
#
# RetroCRT is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# RetroCRT is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with RetroCRT.  If not, see <https://www.gnu.org/licenses/>.
##############################################################################

retrocrt_divider="# RetroCRT: Do not add or edit anything below this line"

source $HOME/.retrocrtrc

if ! (grep -wq "$1" $retrocrt_install/retrocrt_timings/no_per_rom_timings.txt); then
    retrocrt_rom_settings="$(egrep "^$ra_rom_basename," $retrocrt_install/retrocrt_resolutions.csv)"
fi

if [[ ! "$retrocrt_rom_settings" ]]; then
    exit
fi

ra_rom_config="$ra_rom.cfg"

if [[ "$retrocrt_rom_settings" ]]; then
    custom_viewport_height="$(cut -d',' -f3 <<< "$retrocrt_rom_settings")"
    rom_monitor_orientation="$(cut -d',' -f4 <<< "$retrocrt_rom_settings")"
fi

sed -i "/$retrocrt_divider/Q" $ra_rom_config

{
cat << SCREENCALC | bc -q
physical_viewport_width = $physical_viewport_width
physical_viewport_height = $physical_viewport_height
custom_viewport_height = $custom_viewport_height

scale=10

custom_viewport_width = physical_viewport_width * (custom_viewport_height / physical_viewport_height)

if (custom_viewport_height >= (physical_viewport_height * 1.25)){
	custom_viewport_height = custom_viewport_height / 2
}

scale = 0

custom_viewport_width = (custom_viewport_width / 1) / 2 * 2
custom_viewport_height = (custom_viewport_height / 1) / 2 * 2


if (custom_viewport_width > physical_viewport_width){
    custom_viewport_width = physical_viewport_width
}

print "$retrocrt_divider\n"
print "custom_viewport_width = " ; custom_viewport_width
print "custom_viewport_height = " ; custom_viewport_height
print "custom_viewport_x = " ; (physical_viewport_width - custom_viewport_width) / 2
print "custom_viewport_y = " ; (physical_viewport_height - custom_viewport_height) / 2
SCREENCALC

if [[ "$rom_monitor_orientation" = "V" ]]; then
cat << RAROMCFG
video_allow_rotate = "true"
video_rotation = "$rotate_ra"
RAROMCFG
fi
} >> "$ra_rom_config"
