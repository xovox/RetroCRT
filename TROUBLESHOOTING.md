# Fixing Issues

Your first step should be to run the RetroCRT tool & update it, then run it again via the RetroPie screen in EmulationStation.

# Reporting Issues

Use RetroCRT's [bug tracking page](https://github.com/xovox/RetroCRT/issues) or join [the Facebook group](https://www.facebook.com/groups/RetroPieCRT/) and post there.

# Video Issues

## Image is too wide

You're not changing the horizontal resolution before starting the emulator, this is an issue with the /opt/retropie/configs/all/runcommand-onstart.sh script.

## Image is too narrow

RetroArch is ignoring our custom_viewport_width setting, and probably the height as well.

### Garbled Colors

You'll need to update /boot/config.txt and set the following to 519 for RetroTink & 0 for all other platforms.

```
dpi_output_format=0
```

