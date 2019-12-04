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

req_packages="
	ansible
	dialog
	git
    python3-dev
	virtualenv
"

bad_backup_string="%Y-%m-%d@%H:%M:%S~"
good_backup_string="%Y%m%d_%H%M%S"
ansible_basic_py="$HOME/.virtualenv/retrocrt/lib/python3.5/site-packages/ansible/module_utils/basic.py"
retrocrt_config="$HOME/.retrocrtrc"
retrocrt_venv="$HOME/.virtualenv/retrocrt"
retrocrt_title="RetroCRT"

export PS4="\[\033[1;30m\]>\[\033[00m\]\[\033[32m\]>\[\033[00m\]\[\033[1;32m\]>\[\033[00m\] "


if [[ ! -f $retrocrt_venv/bin/activate ]]; then
	echo "########################################"
    echo "Generating Python 3 Virtual Env"
	echo "########################################"
	virtualenv --python=python3 $HOME/.virtualenv/retrocrt
fi

for rcfile in $retrocrt_config $retrocrt_venv/bin/activate ; do
	if [[ -f "$retrocrt_config" ]]; then
		source "$rcfile"
	fi
done

retrocrt_install=${retrocrt_install:-$PWD}
	
if [[ "$VIRTUAL_ENV" = "$retrocrt_venv" ]]; then
	echo "########################################"
    echo "Ensuring Virtual Env has Latest Ansible"
	echo "########################################"
	pip install --upgrade ansible
fi

##############################################################################
# make an dos happy backup file template
##############################################################################

if grep -wq "$bad_backup_string" $ansible_basic_py ; then
    sed -i.$(date +%Y%m%d_%H%M%S) "s/$bad_backup_string/$good_backup_string/" \
        $ansible_basic_py
fi

licensea="
RetroCRT :: Configure RetroPie for an analog CRT

Copyright (C) 2019 Duncan Brown (\Zb\Z4https://github.com/xovox\Zn)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

(Continued on next screen)
"

licenseb="
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see \Zb\Z4https://www.gnu.org/licenses/\Zn
"

description="
RetroCRT is a suite of tools and configurations put together to enable the use of CRTs with the a Raspberry Pi running RetroPie.

It achieves this by switching resolutions on the fly based on what platform or arcade rom you're currently using.

Find developers, users, and support in our official Facebook group: \"RetroPie CRT Gamers\".
"

hardware="
This software requires specialized hardware.

The currently tested hardware is:

- RetroTink over component & RGB
- VGA666 over RGB
- pi2scart over RGB SCART

Future supported hardware:

- RetroTink S-Video & composite
- Internal 3.5mm composite

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

--------------------------------

"

rotation="
Would you like to rotate the screen?  This requires a reboot.
"

fatalquit="
Networking is down & we're missing the ansible package.

I'm unable to proceed.
"

bilinearmsg="
RetroCRT is designed to work with ROMs greater than 240p, all the way up to 256p.  These higher resolutions will not render properly on a consumer CRT TV @ 240p.

You have three choices on how to handle these games.

- Keep original display size, but vertically centered.

- Scale down to 240p, dropping some lines.  On some games this will not be very noticible.

- Scale down to 240p, but use bilinear filtering to smooth some of the rough edges.  Some lines will look slightly strange.
"

#video_smooth = "false"

#rotate_tv="$(dialog --title "$retrocrt_title :: Large Screen Games" --stdout --default-item "$rotate_tv" --menu "Which way is up?" 0 0 0 0 "^" 90 ">" 180 "v" 270 "<")"

##############################################################################
# are we being run in the ight dir?
##############################################################################

if [[ "$PWD" != "$retrocrt_install" ]]; then
    echo -e "Please move the installer directory to \"$retrocrt_install\"\n"
    exit
        errorExit="true"
fi

##############################################################################
# can we hit the internet?
##############################################################################

if ping -c 1 -w 1 8.8.8.8 > /dev/null 2>&1; then
    network_up=true
else
    network_up=false
fi

##############################################################################
# license & about the project
##############################################################################

dialog --title "$retrocrt_title :: License & Warranty"	--colors			--msgbox "$licensea"		25 36
dialog --title "$retrocrt_title :: License & Warranty"	--colors			--msgbox "$licenseb"		25 36
dialog --title "$retrocrt_title :: About"		--colors			--msgbox "$description"		25 36
dialog --title "$retrocrt_title :: Supported Hardware"	--colors			--msgbox "$hardware"		25 36

##############################################################################
# first warning
##############################################################################

dialog --title "$retrocrt_title :: Warning"		--colors	--defaultno	--yesno "$warning"		25 36 || exit

##############################################################################
# update before proceding?
##############################################################################

#if dialog --title "$retrocrt_title :: Check Updates"	--colors	--defaultno	--yesno "$checkupdates"		25 36 ; then
if [[ "$network_up" = "true" ]]; then
    git fetch
    if dialog --title "$retrocrt_title :: Update Status" --colors --defaultno --yesno "$updategit$(git status -u no)" 25 36 ; then
        git pull
        $0
        exit
    fi
fi

##############################################################################
# do we want to rotate our screen?
##############################################################################

# up	es	ra	degrees
# ^	0	0	0
# >	1	3	90
# v	2	2	180
# <	3	1	270

rotate_tv=${rotate_tv:-0}

if [[ "$rotate_tv" = "0" ]]; then
    rotate_tv_default="--defaultno"
fi

rotate_tv="$(dialog --title "$retrocrt_title :: Screen Orientation" --stdout --default-item "$rotate_tv" --menu "Which way is up?" 0 0 0 0 "^" 90 "<" 180 "v" 270 ">")"

if [[ "$rotate_tv" = "0" ]]; then
    rotate_es="0"
    rotate_ra="0"
elif [[ "$rotate_tv" = "90" ]]; then
    rotate_es="3"
    rotate_ra="1"
elif [[ "$rotate_tv" = "180" ]]; then
    rotate_es="2"
    rotate_ra="2"
elif [[ "$rotate_tv" = "270" ]]; then
    rotate_es="1"
    rotate_ra="3"
fi

##############################################################################
# our crt connection
##############################################################################

retrocrt_hardware="${retrocrt_hardware:-rt_rgb}"
#retrocrt_hardware="$(dialog --title "$retrocrt_title :: Hardware Used" --stdout --default-item "$retrocrt_hardware" --menu "What CRT Connection?" 0 0 0 rt_rgb "RetroTink: RGB/Component" rt_svid "RetroTink: S-Video" rt_comp "RetroTink: Composite" 35 "3.5mm Jack")"

retrocrt_hardware_list='
  lo18 "240p VGA/GERT666, pi2jamma, pi2scart"
  hi18 "480p VGA/GERT666, pi2jamma, pi2scart"
  lo24 "240p RetroTink Ultimate RGB & VGA
  hi24 "480p RetroTink Ultimate RGB & VGA
  ntsc24 "240p NTSC RetroTink Component"
  pal24 "240p PAL RetroTink Component"
  35n "NTSC Built-In Composite"
  35p "PAL Built-In Composite"
'

retrocrt_hardware="${retrocrt_hardware:-lo18}"

if [[ "$retrocrt_platform" = "lo18" ]]; then
    retrocrt_timings="rgb/15khz"
    retrocrt_depth="18"
elif [[ "$retrocrt_platform" = "hi18" ]]; then
    retrocrt_timings="rgb/31khz"
    retrocrt_depth="18"
elif [[ "$retrocrt_platform" = "lo24" ]]; then
    retrocrt_timings="rgb/15khz"
    retrocrt_depth="24"
elif [[ "$retrocrt_platform" = "hi24" ]]; then
    retrocrt_timings="rgb/31khz"
    retrocrt_depth="24"
elif [[ "$retrocrt_platform" = "ntsc24" ]]; then
    retrocrt_timings="ntsc/15khz"
    retrocrt_depth="24"
elif [[ "$retrocrt_platform" = "pal24" ]]; then
    retrocrt_timings="pal/15khz"
    retrocrt_depth="24"
elif [[ "$retrocrt_platform" = "35n" ]]; then
    retrocrt_timings="35/ntscp"
    retrocrt_depth="18"
elif [[ "$retrocrt_platform" = "35p" ]]; then
    retrocrt_timings="35/pal"
    retrocrt_depth="18"
fi
##############################################################################
# choose a tv region
##############################################################################

tv_region=${tv_region:-ntsc}
#tv_region"$(dialog --stdout --default-item "$tv_region --menu "What region are you?" 0 0 0 NTSC "NTSC" PAL "PAL" SECAM "SECAM")"

##############################################################################
# one last chance to bail
##############################################################################

dialog --title "$retrocrt_title :: Last Chance!" --colors --defaultno --yesno "$finalwarning" 25 36 || exit

clear

##############################################################################
# write our config
##############################################################################

cat << CONFIG > $retrocrt_config
#!/bin/bash
$license

# the resolution our pi will output, platforms work within this constraint
physical_viewport_width=1920
physical_viewport_height=240

# where we keep everything
export retrocrt_install="$retrocrt_install"

export tv_region="$tv_region"

export rotate_tv="$rotate_tv"
export rotate_es="$rotate_es"
export rotate_ra="$rotate_ra"

export retrocrt_hardware="$retrocrt_hardware"

# our per-system video modes
export retrocrt_timings="\$retrocrt_install/retrocrt_timings/\$tv_region/\$retrocrt_hardware"

export PATH="\$retrocrt_install/bin:\$PATH"

# keep ansible from creating ugly .retry files
export ANSIBLE_RETRY_FILES_ENABLED=0
CONFIG

##############################################################################
# pull in our config
##############################################################################

source $retrocrt_config

##############################################################################
# install ansible
##############################################################################

if ! (dpkg -l $req_packages > /dev/null); then
    if [[ "$network_up" = "true" ]]; then
        sudo apt update
        sudo apt -y install $req_packages
    else
        dialog --title "$retrocrt_title :: Fatal Error"	--colors			--msgbox "$fatalquit"		25 36
        exit
    fi
fi

##############################################################################
# Run our configuration playbook
##############################################################################

echo "########################################"
echo "Running RetroCRT Ansible Playbook"
echo "########################################"
echo

set -x
ansible-playbook RetroCRT.yml -i localhost,

sleep 5
