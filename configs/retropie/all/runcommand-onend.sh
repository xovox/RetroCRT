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

source $HOME/.retrocrtrc

# Change Screen mode back
export ra_system=default
retrocrt_timings


#grep -q "Fatal error" /dev/shm/runcommand.log && {
#	sleep 5
#	egrep -B 1 -A 100 "Fatal error" /dev/shm/runcommand.log
#	sleep 15
#}
