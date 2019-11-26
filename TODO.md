#Setup Script

* Add new hardware choices
-[ ] 18rgb - VGA666/pi2scart/pi2jamma
-[ ] 24rgb - RetroTink RGB, VGA
-[ ] 24svid - RetroTink S-Video
-[ ] 24ntsc - RetroTink Component NTSC
-[ ] 24pal - RetroTink Component PAL
-[ ] 24cps - RetroTink Composite
-[ ] 35mm - Internal Jack


#Timings Dirs

# Ansible Optimization

-[ ] https://garthkerr.com/using-ansible-template-for-partial-file-block/

I feel like the retroarch config updates could be done in an item loop, maybe with a template

```
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
