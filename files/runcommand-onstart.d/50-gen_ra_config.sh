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

# if this platform isn't in our list of no per-rom resolutions...
if ! (grep -wq "$1" $retrocrt_install/retrocrt_timings/no_per_rom_timings.txt); then
    # check for a per-rom resolution
    retrocrt_rom_settings="$(egrep "^$ra_rom_basename," $retrocrt_install/retrocrt_resolutions.csv)"
fi

# if we're unable to find anything, exit
if [[ ! "$retrocrt_rom_settings" ]]; then
    exit
fi

# the RA config we're going to update
ra_rom_config="$ra_rom.cfg"

# extract our resolution & orientation information
if [[ "$retrocrt_rom_settings" ]]; then
    custom_viewport_height="$(cut -d',' -f3 <<< "$retrocrt_rom_settings")"
    custom_viewport_width="$(cut -d',' -f2 <<< "$retrocrt_rom_settings")"
    rom_monitor_orientation="$(cut -d',' -f4 <<< "$retrocrt_rom_settings")"
fi

# delete anything we've already written to the config
old_config="$(sed "/$retrocrt_divider/Q" $ra_rom_config)"

rm "$ra_rom_config"

squishy() {
cat << SQUISHY
custom_viewport_width = 1210
custom_viewport_height = 240
custom_viewport_x = $[ (1920 - 1210) / 2 ]
SQUISHY
	exit
}

# everything between these brackets is used to write the config
{
echo "$old_config"
echo "$retrocrt_divider"
cat << GLOBAL
video_allow_rotate = "true"
video_rotation = "$rotate_ra"
GLOBAL

if [[ "$rom_monitor_orientation" = "V" ]] && [[ "$rotate_ra" =~ [02] ]]; then
	if [[ "$custom_viewport_width" != "240" ]]; then
		echo video_smooth = true
	fi
	squishy
fi

if [[ "$rom_monitor_orientation" = "H" ]] && [[ "$rotate_ra" =~ [13] ]]; then
	squishy
fi

# add our divider
cat << SCREENCALC | bc -q
physical_viewport_width = $physical_viewport_width
physical_viewport_height = $physical_viewport_height
custom_viewport_height = $custom_viewport_height

# scale it up so we can get good percentage calculation
scale=10

# if game's requested resolution >= 125% of available, cut it in half
# see pigskin 621 AD & popeye.  these are 240p games with some 480
# sprites.  
if (custom_viewport_height >= (physical_viewport_height * 1.25)){
	custom_viewport_height = custom_viewport_height / 2
}

# get percentage of vertical screen used, and use that to calculate our horizontal
custom_viewport_width = physical_viewport_width * (custom_viewport_height / physical_viewport_height)

# let's only return ints from here on out
scale = 0

# let's make sure our resolution is divisible by 2
custom_viewport_width = (custom_viewport_width / 1) / 2 * 2
custom_viewport_height = (custom_viewport_height / 1) / 2 * 2

# limit games to max out at our top horizontal resolution
if (custom_viewport_width > physical_viewport_width){
    custom_viewport_width = physical_viewport_width
}

# output our resolution settings
print "custom_viewport_width = " ; custom_viewport_width
print "custom_viewport_height = " ; custom_viewport_height
print "custom_viewport_x = " ; (physical_viewport_width - custom_viewport_width) / 2
print "custom_viewport_y = " ; (physical_viewport_height - custom_viewport_height) / 2
print "video_rotation = $rotate_ra\n"
SCREENCALC

#fi
} >> "$ra_rom_config"
