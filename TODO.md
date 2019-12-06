# General

remove all mentions of pi user/group, we should use a variable

RetroCRT.sh probably doesn't need to sudo

# /boot/config.txt or /boot/retrocrt.txt
* should have directives to configure stuff like pi2jamma/etc

# console updates

i want to try to use the retrocrt es theme font for the console if possible
* https://retropie.org.uk/forum/topic/11030/instructions-how-to-permanently-enlarge-alter-font-and-font-size/2

```
# CONFIGURATION FILE FOR SETUPCON

# Consult the console-setup(5) manual page.

ACTIVE_CONSOLES="/dev/tty[1-6]"

CHARMAP="UTF-8"

CODESET="guess"
FONTFACE="Terminus"
FONTSIZE="6x12"

VIDEOMODE=

# The following is an example how to use a braille font
# FONT='lat9w-08.psf.gz brl-8x8.psf'
```

# bashrc update

retropie have the banner print even when you're trying rsync or scp, we need to block that

# timings

15khz standard
```
320 1 20 37 55 240 1 2 3 16 0 0 0 60 0 6400000 1
```

15khz gaming
```
1920 1 80 224 465 240 1 2 3 16 0 0 0 60 0 42109740 1
```

# Setup Script

* Add new hardware choices
- [ ] 18rgb - VGA666/pi2scart/pi2jamma
- [ ] 24rgb - RetroTink RGB, VGA
- [ ] 24svid - RetroTink S-Video
- [ ] 24ntsc - RetroTink Component NTSC
- [ ] 24pal - RetroTink Component PAL
- [ ] 24cps - RetroTink Composite
- [ ] 35mm - Internal Jack

# Screen Resolution

I'm probably making things more complicated than they need to be, but I want to make it flexible if someone wants to go higher or lower than 1920

## Even Numbers

Arcade games have math applied on load that makes sure our resolution is an even number

Console/handheld platforms need to be done as well

# Ansible Optimization

* Read in resolution from env & convert to int
  * https://www.mydailytutorials.com/ansible-arithmetic-operations/
* https://garthkerr.com/using-ansible-template-for-partial-file-block/

# pi2jamma controls

* https://medium.com/bigpanda-engineering/using-ansible-to-compile-nginx-from-sources-with-custom-modules-f6e6c6a42493

```yaml
---

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

- hosts: "localhost"
  connection: "local"
  become: "yes"
  become_user: "root"

  tasks:

    - name: "pikeyd: compile"
      make:
        chdir: "/home/pi/RetroCRT/pikeyd"
```

# vertical games that had a 240 horizontal resolution so they look great on 240p horizontal orientation

```
Andromeda
Battle Lane! Vol. 5
BlockBuster
Burger Time
Burnin' Rubber
Cook Race
Cosmos
Crazy Blocks
Dark Warrior
Darwin 4078
Dazzler
Digger
Disco No.1
Dommy
Dorodon
Eggs
Gold Bug
Graplop
Heart Attack
Hero
Hunchback Olympic
Hunchback
IPM Invader
Jackal
Jumping Jack
Lady Bug
Lock'n'Chase
Logger
Minky Monkey
MotoRace USA
Mr. Do!
Mr. Do's Castle
Mr. Do!
Mr. Do vs. Unicorns
Mr. Du!
Mr. Jong
Mr. Lo!
Mustache Boy
Night Star
Noah's Ark
Outline
Pro Soccer
Radar Zone
Raiders
Red Clash
Rock Duck
Scrambled Egg
Shot Rider
Sky Chuter
Space Fortress
Space Raider
Strike Bowling
Superbike
Tennis
The Berenstain Bears in Big Paw's Cave
Tokushu Butai Jackal
Top Gunner
Traverse USA / Zippy Race
Treasure Island
Tugboat
Video Eight Ball
Wall Street
World Tennis
Yankee DO!
Youma Ninpou Chou
Zero Hour
```


# Branch browser?

* https://stackoverflow.com/questions/5188320/how-can-i-get-a-list-of-git-branches-ordered-by-most-recent-commit
```
git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)'

for i in $(git branch -a | grep remotes/origin | cut -d'/' -f3 | grep -v HEAD) ; do
	echo  "$i  $(git config branch.$i.description)"
done | column -t -s '     '
```
