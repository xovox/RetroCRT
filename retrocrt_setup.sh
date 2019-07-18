#!/bin/bash

license="
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
"

retroCRT=$HOME/RetroCRT
retroCRTconfig=$retroCRT/config

if [ -f "$retroCRTconfig" ]; then
	source "$retroCRTconfig"
fi

title="RetroCRT Installer"

greetings="
RetroCRT :: Utility suite to configure RetroPie for an analog CRT

Copyright (C) 2019 Duncan Brown (\Zb\Z4https://github.com/xovox\Zn)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see \Zb\Z4https://www.gnu.org/licenses/\Zn
"

description="
This software requires specialized hardware.  Currently, only the RetroTink Ultimate has been tested.

Future updates will support built-in composite, VGA666 RGB, pi2scart.

If you don't have the required hardware, this will not work.
"

warning="
\Zb\Z1THIS WILL OVERWRITE MANY MANY THINGS!\Zn

Please be sure to have run a full RetroPie upgrade as well as update all of your system packages first!

Are you actually ready?
"

finalwarning="
\Zb\Z1LAST CHANCE!!! BACKUP YOUR INSTALLATION!!!\Zn

This installer overwrites many critical configs.  This is best run on a clean RetroPie installation.

Last chance, are you sure you wish to continue?
"

updategit="
Update RetroCRT installer and configs before we continue?

This will restart the installer.

----------------------------------------

"

rotation="
Would you like to rotate EmulationStation?

This requires the experimental version of EmulationStation to be installed via RetroPie-Setup.
"

noansible="
You're missing the ansible package, and networking is down.

I'm unable to proceed.
"

##############################################################################
# license & about the project
##############################################################################

dialog --title "$title :: License & Warranty"	--colors			--msgbox "$greetings"		0 0
dialog --title "$title :: About"		--colors			--msgbox "$description"		0 0

if ping -c 1 -w 1 8.8.8.8 > /dev/null 2>&1; then
	networkUp=true
else
	networkUp=false
fi

##############################################################################
# first warning
##############################################################################

dialog --title "$title :: Warning"		--colors	--defaultno	--yesno "$warning"		0 0 || exit

##############################################################################
# update before proceding?
##############################################################################

#if dialog --title "$title :: Check Updates"	--colors	--defaultno	--yesno "$checkupdates"		0 0 ; then
if [ "$networkUp" = "true" ]; then
	git fetch
	if dialog --title "$title :: Update Status" --colors --defaultno --yesno "$updategit$(git status -u no)" 0 0 ; then
		git pull
		$0
		exit
	fi
fi

##############################################################################
# do we want to rotate our screen?
##############################################################################

# up	es	ra
# ^	0	0
# >	1	3
# v	2	2
# <	3	1

tvRotation=${tvRotation:-0}

if [ "$tvRotation" = "0" ]; then
	tvRotationDefault="--defaultno"
fi

if dialog --title "$title :: Screen Orientation" --colors $tvRotationDefault --yesno "$rotation" 0 0 ; then
	tvRotation="$(dialog --title "$title :: Screen Orientation" --stdout --default-item "$tvRotation" --menu "Which way is up?" 0 0 0 0 "^" 90 ">" 180 "v" 270 "<")"
else
	tvRotation=0
fi

if [ "$tvRotation" = "0" ]; then
	esRotation="0"
	raRotation="0"
elif [ "$tvRotation" = "90" ]; then
	esRotation="3"
	raRotation="1"
elif [ "$tvRotation" = "180" ]; then
	esRotation="2"
	raRotation="2"
elif [ "$tvRotation" = "270" ]; then
	esRotation="1"
	raRotation="3"
fi

##############################################################################
# choose a tv region
##############################################################################

tvRegion=${tvRegion:-ntsc}
#tvRegion="$(dialog --stdout --default-item "$tvRegion" --menu "What region are you?" 0 0 0 NTSC "NTSC" PAL "PAL" SECAM )"

##############################################################################
# one last chance to bail
##############################################################################

dialog --title "$title :: Last Chance!" --colors --defaultno --yesno "$finalwarning" 0 0 || exit

##############################################################################
# write our config
##############################################################################

cat << CONFIG > $retroCRTconfig
#!/bin/bash

$license

# where we keep everything
export retroCRT="/home/pi/RetroCRT"

export tvRegion="$tvRegion"

export tvRotation="$tvRotation"
export esRotation="$esRotation"
export raRotation="$raRotation"

# our per-system video modes
export hdmiTimings=$retroCRT/hdmi_timings/$tvRegion

export PATH=\$retroCRT/bin:\$PATH

# keep ansible from creating ugly .retry files
export ANSIBLE_RETRY_FILES_ENABLED=0
CONFIG

##############################################################################
# pull in our config
##############################################################################

source $retroCRTconfig

if [ "$PWD" != "$retroCRT" ]; then
	echo -e "Please move this directory to \"$retroCRT\"\n"
        errorExit="true"
fi

if [ "$errorExit" ]; then
	exit
fi

clear

##############################################################################
# install ansible
##############################################################################

if ! (dpkg -l ansible > /dev/null); then
	if [ "$networkUp" = "true" ]; then
		sudo apt update
		sudo apt -y install ansible
	else
		dialog --title "$title :: Fatal Error"	--colors			--msgbox "$noansible"		0 0
		exit
	fi
fi

##############################################################################
# Run our configuration playbook
##############################################################################

ansible-playbook RetroCRT.yml -i localhost,
