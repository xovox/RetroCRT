# Video Issues

## Image is too wide

You're not changing the horizontal resolution before starting the emulator, this is an issue with the /opt/retropie/configs/all/runcommand-onstart.sh script.

## Image is too narrow

RetroArch is ignoring our custom_viewport_width setting, and probably the height as well.  This happens when you run the RetroPie updater.

# Sound Issues

## No Sound

You don't have audio set to go out the 3.5mm jack.  This is set in RetroCRT's config.txt, it must have been overwritten.
