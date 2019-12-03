# General

remove all mentions of pi user/group, we should use a variable

RetroCRT.sh probably doesn't need to sudo

# Setup Script

* Add new hardware choices
- [ ] 18rgb - VGA666/pi2scart/pi2jamma
- [ ] 24rgb - RetroTink RGB, VGA
- [ ] 24svid - RetroTink S-Video
- [ ] 24ntsc - RetroTink Component NTSC
- [ ] 24pal - RetroTink Component PAL
- [ ] 24cps - RetroTink Composite
- [ ] 35mm - Internal Jack

# Timings Dirs

# Screen Resolution

I'm probably making things more complicated than they need to be, but I want to make it flexible if someone wants to go higher or lower than 1920

## Even Numbers

Arcade games have math applied on load that makes sure our resolution is an even number

Console/handheld platforms need to be done as well

## Handhelds

Handhelds aren't 4:3, so my current blanket math doesn't work for them.

this should work for 15khz & 31khz

```
handheld_horizontal * (physical_horizontal / virtual_horizontal)
```


| System | Resolution | Math |
| ------ | ---------- | ---- |
| atarilynx | 160x102 | |
| gamegear | 160x144 | |
| gb | 160x144 | |
| gbc | 160x144 | |
| gba | 240x160 | |
| ngp | 160x152 | |
| ngpc | 160x152 | |
| virtualboy | 384x224 | |
| wonderswan | 224x144 | |
| wonderswancolor | 224x144 | |

# Ansible Optimization

* Read in resolution from env & convert to int
  * https://www.mydailytutorials.com/ansible-arithmetic-operations/
* https://garthkerr.com/using-ansible-template-for-partial-file-block/

I feel like the retroarch config updates could be done in an item loop, maybe with a template

```yaml
    - name: "Configure Resolutions"
      blockinfile:
        path: '/opt/retropie/configs/{{item.platform}}/retroarch.cfg'
        backup: 'yes'
        block: |
          custom_viewport_height = {{ item.custom_viewport_height }}
          custom_viewport_width = {{ item.custom_viewport_width }}
      loop:
        - { platform: gba, custom_viewport_height: 160, custom_viewport_width: "{{ gba_custom_viewport_width }}" }
```

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
