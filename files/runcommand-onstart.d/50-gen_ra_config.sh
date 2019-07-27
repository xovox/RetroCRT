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

source $HOME/.retrocrtrc

rom_settings="$(egrep "^$ra_rom_basename," $retrocrt_install/retrocrt_resolutions.csv)"
ra_rom_config="$ra_rom.cfg"

gen_ra_rom_config() {
cat << RAROMCFG
custom_viewport_width = "1920"
custom_viewport_height = "$rom_vertical_resolution"
RAROMCFG

if [[ "$rom_vertical_resolution" -gt 240 ]]; then
cat << RAROMCFG
custom_viewport_y = "-$[ ($rom_vertical_resolution - 240) / 2 ]"
RAROMCFG
fi

if [[ "$rom_monitor_orientation" = "V" ]]; then
cat << RAROMCFG
video_allow_rotate = "true"
video_rotation = "$rotate_ra"
RAROMCFG
fi
}

if [[ "$rom_settings" ]]; then
    rom_vertical_resolution="$(cut -d',' -f3 <<< "$rom_settings")"
    rom_monitor_orientation="$(cut -d',' -f4 <<< "$rom_settings")"
    gen_ra_rom_config > "$ra_rom_config"
fi
