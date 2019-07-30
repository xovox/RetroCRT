# Fixing Issues

Your first step should be to run the RetroCRT tool via the RetroPie screen in EmulationStation.

# Reporting Issues

Use GitHub's built-in bug tracking or join [the Facebook group](https://www.facebook.com/groups/RetroPieCRT/) and post there.

# Video Issues

## Image is too wide

You're not changing the horizontal resolution before starting the emulator, this is an issue with the /opt/retropie/configs/all/runcommand-onstart.sh script.

## Image is too narrow

RetroArch is ignoring our custom_viewport_width setting, and probably the height as well.

# Sound Issues

## No Sound

You don't have audio set to go out the 3.5mm jack.  This is set in RetroCRT's config.txt, it must have been overwritten.
