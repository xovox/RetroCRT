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

# The Gist!

If you're looking to connect your Raspberry Pi running RetroPie to an old school CRT set.  You're going to need a few things.

## Lowest End, Composite

NOTE: This method isn't yet supported by RetroCRT, but it will be.

You're going to need a cable with a 3.5mm (1/8th in) connector cable on one end and video/sound connectors on the other end.  There are many cables that look exactly the same on the outside, but are wired differently on the inside.

* OS Configuration Required
  * Standard Raspberry Pi distros support it out of the box, with configuration
  * RetroCRT will support this out of the box in the future

* Software That Supports Connection
  * All Raspberry Pi distros

* Hardware Required
  * CRT with composite input
  * [Zune A/V Output Cable](https://www.amazon.com/Zune-Output-Cable-Discontinued-Manufacturer/dp/B000IXLHOM).
  * [Generic Pi AV Cable](https://thepihut.com/products/av-composite-cable-3-5mm-to-3-x-rca-3m)

* Advantages
  * Low cost of entry
  * You can use 480i for menus
  * You can use 240p for games
  * Looks decent on small screens
  * Incredibly common on most CRTs

* Disadvantages
  * Luma (light) and Chroma (color) are both carried on the same signal, so they interfere with each other
  * This is the lowest quality video output you can get on the Pi
  * This is prone to [dot crawl](https://en.wikipedia.org/wiki/Dot_crawl)

## Mid-Range, S-Video

[S-Video](https://en.wikipedia.org/wiki/S-Video) is a decent step up from Composite.  You're separating Luma and Chroma which gives you far less interference, and better color depth.

* OS Configuration Required
  * Customized Raspberry Pi OSs with specific timings set for S-Video, as well as setting video output over GPIO

* OS Support
  * [RetroTink Ultimate](http://www.retrotink.com)'s LAKKA image.
  * RetroCRT will support this in the future

* Hardware
  * CRT with S-Video input
  * [RetroTink Ultimate](http://www.retrotink.com) gives you 16,777,216 colors.

* Advantages
  * Better colors than composite
  * Less interference
  * Better clarity than component
  * Fairly common on CRTs

* Disadvantages
  * Not natively supported by a Raspberry Pi
  * Additional hardware is required

## Lower High-Range, Component/YPbPr

[Component video](https://en.wikipedia.org/wiki/Component_video) actually encompases *many* video formats, but in NA it typically refers to a specific type of video called [YPb/Pr](https://en.wikipedia.org/wiki/YPbPr)... sort of the way we call all facial tissue Kleenex.

This format separates the red and blue signals from luma, and derives the green signal based on the red, blue, and luma signals.

* OS Configuration Required
  * Customized Raspberry Pi OS with specific timings set for component, as well as setting video output over GPIO

* OS Support
  * [RetroCRT](https://github.com/xovox/RetroCRT)'s RetroPie image
  * [RetroTink Ultimate](http://www.retrotink.com)'s LAKKA image.

* Hardware Required
  * CRT with Component/YPbPr input
  * [RetroTink Ultimate](http://www.retrotink.com) gives you 16,777,216 colors.

* Advantages
  * Output at 240p
  * Output at 480p, or 720p possible on HDTVs
  * Very high color depth and clarity
  * Fairly common on higher-end CRTs, which are very cheap/free by now
  * Cheap cables

* Disadvantages
  * Requires moderately expensive hardware
  * Stuck at 240p or lower on standard CRTs
  * Fairly pricy hardware is required

## Upper High-Range, RGB

* Software Required
  * Customized Raspberry Pi OS with specific timings set for RGB, as well as setting video output over GPIO

* OS Support
  * [RetroCRT](https://github.com/xovox/RetroCRT)'s RetroPie image
  * [RetroTink Ultimate](http://www.retrotink.com)'s LAKKA image.

* Hardware Required
  * Not region specific
  * RGB SCART CRT TV
  * RGB monitor (typical VGA)
  * RGB modded CRT TV
  * Professional RGB CRTs, typically used in media creation
  * The affordable Gert/VGA 666 gives you 18-bit (262,144) color.
    * [North America](https://www.amazon.com/Raspberry-Adapter-Board-Atomic-Market/dp/B075DM4C5V)
    * [Europe](https://uk.pi-supply.com/products/gert-vga-666-hardware-vga-raspberry-pi)
  * The more expensive [RetroTink Ultimate](http://www.retrotink.com) gives you 24-bit (16,777,216) color.

* Advantages
  * Fairly cheap hardware available
  * Incredible color depth, accuracy, and clarity.  At, or near, arcade quality.
  * Inexpensive and open-sourced hardware is required
  * SCART is common in many countries
  * Many CRTs can be modded to accept this signal
  * Not affected by PAL/NTSC/SECAM regions
  * Can be used with a VGA CRT

* Disadvantages
  * CRTs with OEM RGB support can be very expensive in the Americas
  * Full 24-bit color depth requires moderately expensive hardwwre
  * SCART isn't generally available in the Americas
  * Can be difficult to find and modify a CRT
  * More expensive cables
