# Some License Nonsense

RetroCRT :: Utility suite to configure RetroPie for a CRT

Copyright (C) 2019 Duncan Brown (https://github.com/xovox)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

# RetroCRT

RetroCRT is a suite of tools designed to make [RetroPie](https://retropie.org.uk) gaming on CRTs easy and user friendly.

Compared to every distro I've seen out there, one of the biggest advantages of using RetroCRT is that we're only updating configuration files line-by-line instead of overwriting everything.  This means that RetroCRT should be able to coexist with RetroPie and probably almost everything else you're running.

## Videos

* [Fresh Install of RetroCRT](https://www.youtube.com/watch?v=nytsuaoU4R8) shows what you get out of the box
* [RetroCRT Theme Demo](https://www.youtube.com/watch?v=6hoH16SXjr0) shows what it looks like populated with snapshots & videos
* [RetroCRT Configuration Files](https://www.youtube.com/watch?v=zDwPPjS4E2w) shows what you have living in /boot that you can edit on your PC, macOS, & Linux computer

## Photo

* [Screenshot](https://raw.githubusercontent.com/xovox/RetroCRT-Media/master/RetroCRT-240p/Small_NES_Mockup.jpg)

# Resources

* [The manual](https://github.com/xovox/RetroCRT/blob/master/MANUAL.md) has a ton of info, read this to get up to speed

* Facebook
  * [RetroPie CRT Gamers](https://www.facebook.com/groups/RetroPieCRT/) is a group I started for this very purpose
  * [The CRT Collective](https://www.facebook.com/groups/444560212348840/) is an excellent resource on TV repair, buying, and general knowledge

# Downloads

[The release page](https://github.com/xovox/RetroCRT/releases) has any, and all, pre-built images ready to go.

# Installation

See [the manual](https://github.com/xovox/RetroCRT/blob/master/MANUAL.md).

# Supported Hardware

* See [the issues page](https://github.com/xovox/RetroCRT/issues) to see planned supported hardware

* Raspberry Pi
  * 3 B & B+ are the only ones tested

* TV: [RetroTink Ultimate](http://www.retrotink.com)
  * Component & RGB only, for now
  * NTSC only, for now
* JAMMA Arcade: [pi2jamma](http://arcadeforge.net/Pi2Jamma-Pi2SCART/Pi2Jamma::248.html)
  * JAMMA controls are currently unsupported, but will be
* RGB: [pi2scart](http://arcadeforge.net/Pi2Jamma-Pi2SCART/PI2SCART::264.html)
* RGB/VGA: [GERT VGA 666](https://github.com/PiSupply/Gert-VGA-666)
  * You can buy it on [Amazon](amazon.com/Raspberry-Adapter-Board-Atomic-Market/dp/B075DM4C5V)

# What You Get

* My 240p EmulationStation theme, [RetroCRT 240p](https://github.com/xovox/es-theme-RetroCRT-240p)!
* Only updates required lines in configs, preserving your personal customizations!
* 240p test suite roms for several console platforms!
* Easy installation!
* Pixel-perfect console emulation!
* Pixel-perfect arcade emulation for most games!
  * This is achieved with on-load screen resolution changes!
* Automatic rotation for vertical games!
* Installation of additional CRT Friendly EmulationStation themes!
* No system messages on boot/shutdown/reboot!
* No annoying EmulationStation yellow text!
* My unbridled enthusiasm about building this project!

# Consumer TV Compatibility

Strictly NTSC TVs at this time

# Troubleshooting

Before doing anything else, update RetroCRT!  You can do this in the RetroPie screen in EmulationStation.

If that doesn't fix it, see the [troubleshooting doc](TROUBLESHOOTING.md).

# Footnotes

I am not affiliated with RetroPie, Mike Chi, RetroTink, pi2jamma, or anyone else.  I'm doing this as a personal project.

Shout out to [Vykran](https://github.com/Vykyan/retroTINK-setup) for the initial groundwork, though he seems to be PAL & I'm NTSC... which brought us to where we are now.

```
                                                       .
                                                       ;\
                                                      /  \
                                                      `.  i          ,^^--.
                                                   ___  i  \        /      \              ,',^-_
                                                  /   \ !   \       |       |            / /   /
                                                  \   /  \   \      |       ;      ,__. |    ,'
                                                   4 |    \   `.    |      /      (    `   __>
                                                 ,_| |_.   \    `-__>      >.      `---'\ /
                                                /,.   ..\   `.               `.         | |
                                                U |   | U     `.               \    ,--~   ~--.
--~~~~--_       _--~~~~--_       _--~~~~--_       _--~~~~--_    \  _--~~~~--_   \  /_--~~~~--_ \
         `.   ,'          `.   ,'          `.   ,'          `.  |,'          `.  \,'          `.
           \ /              \ /              \ /              \ /              \ /              \
```
