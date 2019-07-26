#!/bin/bash

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

# $1 - system
# $2 - emulator in use
# $3 - full path to rom
# $4 - full emulator command line

(
set -x
source $HOME/.retrocrtrc

export ra_system="$1"
export ra_emulator="$2"
export ra_rom="$3"
export ra_command="$4"

export ra_rom_stripped="${ra_rom%.*}"
export ra_rom_basename="$(basename "$ra_rom_stripped")"

retrocrt_timings

if [[ -x $HOME/bin/rcrt ]]; then
	$HOME/bin/rcrt
fi
) > /tmp/runCommandOnStart.out 2>&1
