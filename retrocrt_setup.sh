#!/bin/bash

# This file is part of RetroCRT (https://github.com/xovox/RetroCRT)

opening_text=(
"
RetroCRT is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

RetroCRT is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
" "
You should have received a copy of the GNU General Public License along with RetroCRT.  If not, see gnu.org/licenses/.
" "
RetroCRT is a suite of tools to simplify the use of CRTs with a Raspberry Pi running RetroPie.

This is achieved via non-destructive updating of configuration files & custom scripts to manage resolutions & orientation per-rom/core.

Bugs: github.com/xovox/RetroCRT/issues

E-Mail: xovox git gmail com

Facebook: facebook.com/groups/RetroPieCRT
" "
RetroCRT requires specialized hardware:

- RetroTink over component & RGB
- VGA666 over RGB (not to VGA monitors)
- Pi2JAMMA over RGB JAMMA harness
- Pi2SCART over RGB SCART

Future supported hardware:

- RetroTink S-Video & composite
- Internal 3.5mm composite
"
)

rotation_opts='
    0 "^"
    90 "> (Currently Buggy in ES)"
    180 "v"
    270 "<"
'

video_out='
    vga666 "VGA666, Pi2JAMMA, Pi2SCART"
    rtrgb "RetroTink: RGB/Component"
'

custom_timing='
    no "Use standard RetroCRT settings"
    yes "Use my custom timings"
'

region_opts='
    ntsc "NTSC"
    pal "PAL"
    secam "SECAM"
'

final_warning="
\Zb\Z1LAST CHANCE TO ABORT!!!\Zn

This suite has been tested, but does update *many* things on your system.  It makes backups of *everything* before overwriting, so reverting is possible.

Last chance, are you sure you wish to continue?
"

update_git="
Update RetroCRT installer and configs before we continue?

This will restart the installer.
"

rotation="
Would you like to rotate the screen?  This requires a reboot.
"

verticalres="
What vertical resolution do you prefer?
"

fatalquit="
Networking is down & we're missing the ansible package.

I'm unable to proceed.
"

bilinearmsg="
RetroCRT is designed to work with ROMs greater than 224/240p, all the way up to 256p.  These higher resolutions will not render properly on a consumer CRT TV @ 240p.

You have three choices on how to handle these games.

- Keep original display size, but vertically centered.

- Scale down to 224/240p, dropping some lines.  On some games this will not be very noticible.

- Scale down to 224/240p, but use bilinear filtering to smooth some of the rough edges.  Some lines will look slightly strange.
"

##############################################################################
# dialog wrappers and config file
##############################################################################
dialog_menu() {
    if [ ! "$rcrtauto" ]; then
        default_item="$(eval "echo \${$1}")"
        dialog_menu_result="$(echo /usr/bin/dialog --title "'$retrocrt_title :: $2'" --default-item "$default_item" --menu "'$3'" 0 0 0 $4 | bash 3>&1 1>&2 2>&3)"
        if [ ! "$dialog_menu_result" ]; then
            exit 1
        fi
        export $1="$dialog_menu_result"
    fi
}

dialog_msg() {
    if [ ! "$rcrtauto" ]; then
        dialog \
            --no-shadow \
            --title "$retrocrt_title :: $1" \
            --colors \
            --msgbox \
            "$2" \
            20 46
    fi
}

dialog_yesno() {
    if [ ! "$rcrtauto" ]; then
        dialog --no-shadow --title "$retrocrt_title :: $1" --colors --defaultno --yesno "$2" 20 46
    fi
}

if [ -f $HOME/RetroCRT/files/dialogrc ]; then
    export DIALOGRC=$HOME/RetroCRT/files/dialogrc
fi

##############################################################################
# our notifications
##############################################################################

if [ "$COLUMNS" ]; then
	rcrtbwidth=$COLUMNS
else
	rcrtbwidth=40
fi

rcrtbanner() {
	rcrtbanner="$1"
	printf %${rcrtbwidth}s | tr ' ' '='
        printf "%*s\n" $(((${#rcrtbanner}+$rcrtbwidth)/2)) "$rcrtbanner"
	printf %${rcrtbwidth}s | tr ' ' '='
	echo
}
set +x

##############################################################################
# pull in our config
##############################################################################

retrocrt_config="/boot/retrocrt/retrocrt.txt"
sudo mkdir -pv /boot/retrocrt
sudo mkdir -pv /boot/retrocrt/custom_timings

#retrocrt_config="$HOME/.retrocrtrc"
#source $retrocrt_config
retrocrt_title="RetroCRT"

# lock in the ansible version we're running
ansible_ver="2.10.8"

retrocrt_venv="$HOME/.virtualenv/retrocrt3"
req_packages="
    dialog
    dos2unix
    git
    python3-apt
    python3-dev
    virtualenv
"

export PS4="   \[\033[1;30m\]>\[\033[00m\]\[\033[32m\]>\[\033[00m\]\[\033[1;32m\]>\[\033[00m\] "

##############################################################################
# can we hit the internet?
##############################################################################

if curl https://www.google.com/ > /dev/null 2>&1; then
    network_up=true
else
    network_up=false
fi

##############################################################################
# Install Required Packages
##############################################################################

if ! (dpkg -l $req_packages > /dev/null); then
    if [[ "$network_up" = "true" ]]; then
        sudo apt-get update --allow-releaseinfo-change
        sudo apt-get -y install $req_packages || exit
    else
        dialog_msg "Fatal Error" "$fatalquit"
        exit
    fi
fi

if [[ ! -f $retrocrt_venv/bin/activate ]]; then
    rcrtbanner "Generating Python 3 Virtual Env"
    virtualenv --python=python3 $retrocrt_venv
fi

if [[ -f $retrocrt_venv/bin/activate ]]; then
    source $retrocrt_venv/bin/activate
fi

if [[ "$VIRTUAL_ENV" = "$retrocrt_venv" ]] && [[ ! "$rcrt_quick" ]]; then
    rcrtbanner "Ensuring Virtual Env has Ansible $ansible_ver"
    pip install --retries 5 --timeout 5 --upgrade --cache-dir /dev/shm ansible-base==$ansible_ver

    rcrtbanner "Ensuring Ansible Modules are Installed"
    ansible-galaxy install -vvvv -r requirements.yml

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

##############################################################################
# are we being run in the right dir?
##############################################################################

export retrocrt_install=${retrocrt_install:-$PWD}
export retrocrt_timings="$retrocrt_install/retrocrt_timings"

if [[ "$PWD" != "$retrocrt_install" ]]; then
    echo -e "Please move the installer directory to \"$retrocrt_install\"\n"
    exit
fi

##############################################################################
# license & about the project
##############################################################################

textpage="0"
for text in "${opening_text[@]}"; do
    textpage=$[ $textpage + 1 ]
        dialog_msg "Greetings! ($textpage/${#opening_text[@]})" "$text" 
done

##############################################################################
# update before proceding?
##############################################################################

disabled_section() {
if [[ "$network_up" = "true" ]]; then
    if dialog_yesno "Update RetroCRT" "$update_git" ; then
        clear ; reset ; clear
        rcrtbanner "Updating RetroCRT and Restarting"
        git pull
        sleep 5
        $0
        exit
    fi
fi
}

##############################################################################
# version browser!
##############################################################################

#if [[ "$network_up" = "true" ]]; then
#	clear ; reset ; clear
#	git fetch --tags
#fi

#git_tag_latest="$(git for-each-ref --format="%(tag)" --sort=-taggerdate --count=1 refs/tags)"

#git_tag=${git_tag:-$git_tag_latest}

#git_tag_list="master \"bleeding edge\" $(git tag -n1 | sed 's/[ ]\+/ "/;s/$/"/')"
#git_tags="$(git tag -n1 | sed 's/[ ]\+/ "/;'"s/$git_tag .*/&*/;"'s/$/"/')"

#echo "$git_tags"
#dialog_menu git_tag "Version Selection" "What version do you want to run?" "$git_tag_list"

##############################################################################
# do we want to rotate our screen?
##############################################################################

# up  es  ra  degrees
# ^   0   0   0
# >   1   3   90
# v   2   2   180
# <   3   1   270

rotate_crt=${rotate_crt:-0}
dialog_menu rotate_crt "Screen Rotation" "Which way is up?" "$rotation_opts"

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

dialog_menu retrocrt_video_hardware "Video Hardware" "What video connection?" "$video_out"

if [ "$retrocrt_video_hardware" = "vga666" ]; then
    export retrocrt_timings="$retrocrt_timings/rgb/15khz"
    export dpi_output_format="0"
elif [ "$retrocrt_video_hardware" = "rtrgb" ]; then
    export retrocrt_timings="$retrocrt_timings/rgb/15khz"
    export dpi_output_format="519"
fi

export retrocrt_video_custom_timing=${retrocrt_video_custom_timing:-no}
dialog_menu retrocrt_video_custom_timing "Custom Timings" "Utilize custom video timing?" "$custom_timing"

if [ "$retrocrt_video_custom_timing" ]; then
    export retrocrt_timings="/boot/retrocrt/custom_timings"
fi

##############################################################################
# see what vertical resolutions are available and present them
##############################################################################
    
#timing_opts="$(ls $retrocrt_timings/*_* | sed 's/.*_//;s/.*/& "Use &p vertical resolution"/')"
export game_resolution=${game_resolution:-1920_240}
#export resolution_opts="$(ls $retrocrt_timings/*_* | sed 's/.*\///;s/.*/& "Use & resolution"/;s/_/x/2')"
#dialog_menu game_resolution "Game Resolution" "What resolution do you wish to use?" "$resolution_opts"

export physical_viewport_width="$(cut -d'_' -f1 <<< "$game_resolution")"
export physical_viewport_height="$(cut -d'_' -f2 <<< "$game_resolution")"

##############################################################################
# choose a tv region
##############################################################################

tv_region=${tv_region:-ntsc}
#dialog_menu tv_region "TV Region" "What region are you in?" "$region_opts"

##############################################################################
# one last chance to bail
##############################################################################

dialog_yesno "Last Chance!" "$final_warning" || exit

clear

if [ ! -f "$HOME/.retrocrt_counter.svg" ]; then
    curl -s "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fxovox%2FRetroCRT%2F&count_bg=%23FF8C00&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false" > "$HOME/.retrocrt_counter.svg" 2> /dev/null
fi

##############################################################################
# write our config
##############################################################################

echo
rcrtbanner "Writing $retrocrt_config"

cat << CONFIG | unix2dos | sudo dd of=$retrocrt_config
#!/bin/bash
$license

##############################################################################
# Where RetroCRT is Installed
##############################################################################

export retrocrt_install="$retrocrt_install"

export git_tag="$git_tag"

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
# Our HDMI Timings
##############################################################################

export retrocrt_timings="$retrocrt_timings"

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

export game_resolution="$game_resolution"
physical_viewport_width=$physical_viewport_width
physical_viewport_height=$physical_viewport_height

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

if [[ "$MACHTYPE" =~ .*x86_64.* ]]; then
    cat "$retrocrt_config"
    exit
fi

rcrtbanner "Running RetroCRT Ansible Playbook"
ansible-playbook RetroCRT.yml -i localhost,

rcrtbanner "Pausing for 5 Seconds"
sleep 5

if [ "$rcrtauto" ]; then
    rcrtbanner "Shutting Down in 1 Minute"
    sudo shutdown --halt +1
fi
