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

for a 15khz screen, i think this would work
horizontal * (1920 / 320)

for a 31khz screen, i think this would work
horizontal * (1920 / 640)


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
