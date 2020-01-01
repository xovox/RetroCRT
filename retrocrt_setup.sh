#!/bin/bash

# This file is part of RetroCRT (https://github.com/xovox/RetroCRT)

licensetext=(
"
RetroCRT is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

RetroCRT is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
" "
You should have received a copy of the GNU General Public License along with RetroCRT.  If not, see gnu.org/licenses/.
"
)

introtext=(
"
RetroCRT is a suite of tools to simplify the use of CRTs with a Raspberry Pi running RetroPie.

This is achieved via non-destructive updating of configuration files & custom scripts to manage resolutions & orientation per-rom/core.

Bugs: github.com/xovox/RetroCRT/issues

E-Mail: xovox git gmail com

Facebook: facebook.com/groups/RetroPieCRT
"
)

hardwaretext=(
"
RetroCRT requires specialized hardware:

- RetroTink over component & RGB
- VGA666 over RGB
- Pi2JAMMA over RGB JAMMA harness
- Pi2SCART over RGB SCART

Future supported hardware:

- RetroTink S-Video & composite
- Internal 3.5mm composite
"
)

##############################################################################
# pull in our config
##############################################################################

retrocrt_config="/boot/retrocrt/retrocrt.txt"
sudo mkdir -pv /boot/retrocrt

#retrocrt_config="$HOME/.retrocrtrc"
#source $retrocrt_config
retrocrt_title="RetroCRT"

# lock in the ansible version we're running
ansible_ver="2.9.1"

retrocrt_venv="$HOME/.virtualenv/retrocrt"
req_packages="
	dialog
	dos2unix
	git
	python3-apt
	python3-dev
	virtualenv
"

export PS4="   \[\033[1;30m\]>\[\033[00m\]\[\033[32m\]>\[\033[00m\]\[\033[1;32m\]>\[\033[00m\] "

finalwarning="
\Zb\Z1LAST CHANCE TO ABORT!!!\Zn

This suite has been tested, but does update *many* things on your system.  It makes backups of *everything* before overwriting, so reverting is possible.

Last chance, are you sure you wish to continue?
"

updategit="
Update RetroCRT installer and configs before we continue?

This will restart the installer.
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

if [ -f $HOME/RetroCRT/files/dialogrc ]; then
	export DIALOGRC=$HOME/RetroCRT/files/dialogrc
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
# Install Required Packages
##############################################################################

if ! (dpkg -l $req_packages > /dev/null); then
    if [[ "$network_up" = "true" ]]; then
        sudo apt update
        sudo apt -y install $req_packages
    else
        dialog \
			--no-shadow \
			--title "$retrocrt_title :: Fatal Error" \
			--colors \
			--msgbox \
			"$fatalquit" \
			20 46
        exit
    fi
fi

if [[ ! -f $retrocrt_venv/bin/activate ]]; then
    echo
	echo "########################################"
    echo "Generating Python 3 Virtual Env"
	echo "########################################"
	virtualenv --python=python3 $retrocrt_venv
fi

if [[ -f $retrocrt_venv/bin/activate ]]; then
	source $retrocrt_venv/bin/activate
fi

if [[ "$VIRTUAL_ENV" = "$retrocrt_venv" ]]; then
	echo
	echo "########################################"
    echo "Ensuring Virtual Env has Ansible $ansible_ver"
	echo "########################################"
    pip install --retries 5 --timeout 5 --upgrade --cache-dir /dev/shm ansible==$ansible_ver
fi

##############################################################################
# make a dos happy backup file template
##############################################################################

bad_backup_string="%Y-%m-%d@%H:%M:%S~"
good_backup_string="%Y%m%d_%H%M%S"
ansible_basic_py="$(find $retrocrt_venv | grep "ansible/module_utils/basic.py$")"

if grep -wq "$bad_backup_string" $ansible_basic_py ; then
    sed -i.$(date +%Y%m%d_%H%M%S) "s/$bad_backup_string/$good_backup_string/" \
        $ansible_basic_py
fi


sudo touch "$retrocrt_config"
eval "$(dos2unix < "$retrocrt_config")"

if [ -f $retrocrt_install/files/dialogrc ]; then
	export DIALOGRC=$retrocrt_install/files/dialogrc
fi

##############################################################################
# are we being run in the right dir?
##############################################################################

retrocrt_install=${retrocrt_install:-$PWD}

if [[ "$PWD" != "$retrocrt_install" ]]; then
    echo -e "Please move the installer directory to \"$retrocrt_install\"\n"
    exit
fi

##############################################################################
# license & about the project
##############################################################################

textpage="0"
for text in "${licensetext[@]}"; do
	textpage=$[ $textpage + 1 ]
	dialog \
		--no-shadow \
		--title "$retrocrt_title :: License & Warranty ($textpage/${#licensetext[@]})"  \
		--colors  \
		--msgbox "$text" \
		20 46
done

textpage="0"
for text in "${introtext[@]}"; do
	textpage=$[ $textpage + 1 ]
	dialog \
		--no-shadow \
		--title "$retrocrt_title :: Introduction ($textpage/${#introtext[@]})"  \
		--colors  \
		--msgbox "$text" \
		20 46
done

textpage="0"
for text in "${hardwaretext[@]}"; do
	textpage=$[ $textpage + 1 ]
	dialog \
		--no-shadow \
		--title "$retrocrt_title :: Hardware ($textpage/${#hardwaretext[@]})"  \
		--colors  \
		--msgbox "$text" \
		20 46
done

##############################################################################
# update before proceding?
##############################################################################

if [[ "$network_up" = "true" ]]; then
    if dialog --no-shadow --title "$retrocrt_title :: Update RetroCRT" --colors --defaultno --yesno "$updategit" 20 46 ; then
		clear ; reset ; clear
		set -x
        git pull
		sleep 5
        $0
        exit
    fi
fi

##############################################################################
# do we want to rotate our screen?
##############################################################################

# up  es  ra  degrees
# ^   0   0   0
# >   1   3   90
# v   2   2   180
# <   3   1   270


rotate_crt=${rotate_crt:-0}

export rotate_crt="$(dialog --no-shadow \
	--title "$retrocrt_title :: Screen Orientation" \
	--stdout \
	--default-item "$rotate_crt" \
	--menu "Which way is up?  This can be changed later." \
	0 0 0 \
		0 "^" \
		90 "> (Currently Buggy in ES)" \
		180 "v" \
		270 "<"
)"

if [[ "$rotate_crt" = "0" ]]; then
    export rotate_es="0"
    export rotate_ra="0"
elif [[ "$rotate_crt" = "90" ]]; then
    export rotate_es="1"
    export rotate_ra="3"
elif [[ "$rotate_crt" = "180" ]]; then
    export rotate_es="2"
    export rotate_ra="2"
elif [[ "$rotate_crt" = "270" ]]; then
    export rotate_es="3"
    export rotate_ra="1"
fi

##############################################################################
# our crt connection
##############################################################################

export dpi_output_format=${dpi_output_format:-0}
export retrocrt_video_hardware=${retrocrt_video_hardware:-vga666}

export retrocrt_video_hardware="$(dialog --no-shadow \
	--title "$retrocrt_title :: Video Hardware" \
	--stdout \
	--default-item "$retrocrt_video_hardware" \
	--menu "What Video Connection?" \
	0 0 0 \
		vga666 "VGA666, Pi2JAMMA, Pi2SCART" \
		rtrgb "RetroTink: RGB/Component"
)"

if [ "$retrocrt_video_hardware" = "vga666" ]; then
	export retrocrt_timings="rgb/15khz"
	export dpi_output_format="0"
elif [ "$retrocrt_video_hardware" = "rtrgb" ]; then
	export retrocrt_timings="rgb/15khz"
	export dpi_output_format="519"
fi

##############################################################################
# our controller connection
##############################################################################

export retrocrt_ctrl_hardware=${retrocrt_ctrl_hardware:-usb}

disabled_section() {
export retrocrt_ctrl_hardware="$(dialog --no-shadow \
	--title "$retrocrt_title :: Controller Hardware" \
	--stdout \
	--default-item "$retrocrt_ctrl_hardware" \
	--menu "Choose Controller Connection" \
	0 0 0 \
		usb "USB" \
		pi2jamma "Pi2JAMMA" \
)"
}

##############################################################################
# choose a tv region
##############################################################################

tv_region=${tv_region:-ntsc}

disabled_section() {
export tv_region="$(dialog --no-shadow \
	--title "$retrocrt_title :: Controller Hardware" \
	--stdout \
	--default-item "$tv_region" \
	--menu "Choose Controller Connection" \
	0 0 0 \
		ntsc "NTSC" \
		pal "PAL" \
		secam "SECAM" \
)"
}

##############################################################################
# one last chance to bail
##############################################################################

dialog --no-shadow --title "$retrocrt_title :: Last Chance!" --colors --defaultno --yesno "$finalwarning" 20 46 || exit

clear

##############################################################################
# write our config
##############################################################################

cat << CONFIG | unix2dos | sudo dd of=$retrocrt_config
#!/bin/bash
$license

##############################################################################
# Where RetroCRT is Installed
##############################################################################

export retrocrt_install="$retrocrt_install"

##############################################################################
# Configure Video Output, Typically Handled by RetroCRT TUI
##############################################################################

# valid settings:
#    vga666  - Most Hardware: vga666, Pi2JAMMA, Pi2SCART
#     rtrgb  - RetroTink Ultimate

export retrocrt_video_hardware="$retrocrt_video_hardware"

# This handles our color depth

# valid settings:
#    0      - 18-bit, Most Hardware
#    519    - 24-bit, RetroTink Ultimate

export dpi_output_format="$dpi_output_format"

##############################################################################
# Screen Rotation, Typically Handled by RetroCRT TUI
##############################################################################

# up  es  ra  degrees
# ^   0   0   0
# >   1   3   90 (Currently Buggy in ES)
# v   2   2   180
# <   3   1   270

export rotate_crt="$rotate_crt"
export rotate_es="$rotate_es"
export rotate_ra="$rotate_ra"

##############################################################################
# Configure Our Controller
##############################################################################

# valid settings:
#    usb    - USB/BlueTooth connected controller

export retrocrt_ctrl_hardware="$retrocrt_ctrl_hardware"

##############################################################################
# Our HDMI Timings
##############################################################################

export retrocrt_timings="\$retrocrt_install/retrocrt_timings/$retrocrt_timings"

##############################################################################
# Our System PATH
##############################################################################

export PATH="\$retrocrt_install/scripts:\$PATH"

##############################################################################
# Ansible Configuration
##############################################################################

export ANSIBLE_RETRY_FILES_ENABLED=0

##############################################################################
# Emulation Resolution, Currently Unused
##############################################################################

physical_viewport_width=1920
physical_viewport_height=240

##############################################################################
# TV Region, Currently Unused
##############################################################################

export tv_region="$tv_region"
CONFIG

##############################################################################
# pull in our config
##############################################################################

#source $retrocrt_config
eval "$(dos2unix < "$retrocrt_config")"

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
