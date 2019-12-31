# RetroPie Image Prep

* Setup loopback for RetroPie image
* Mount / & /boot in /tmp
* Disable resize-on-boot
* Enable ssh on boot
* Update config.txt

```
rpimage="retropie-4.5.1-rpi2_rpi3.img"
loopback="$(sudo losetup -Pf --show $rpimage)"
rootmnt="$(mktemp -d)"
bootmnt="$(mktemp -d)"
sudo mount ${loopback}p1 $bootmnt
sudo mount ${loopback}p2 $rootmnt
sudo sed -i '/END INIT INFO/a exit 0 # RetroCRT' $rootmnt/etc/init.d/resize2fs_once
sudo touch $bootmnt/ssh

cat << EOF | sudo tee -a $bootmnt/config.txt
dtoverlay=dpi24
enable_dpi_lcd=1
display_default_lcd=1
dpi_group=2
dpi_mode=87
disable_splash=1
hdmi_timings=320 1 16 30 34 240 1 2 3 22 0 0 0 60 0 6400000 1

# 519 for RetroTink Ultimate
# 0 for everything else
dpi_output_format=0
EOF

sudo umount $bootmnt
sudo umount $rootmnt
sudo losetup -D $loopback
```

# Writing Image

* We zero-out the first 1MB of the SD card to remove all metadata/boot/etc
* 'sync' is called several times to ensure we've written everything in cache
* partprobe is called to inform the kernel of partition changes
* pv gives us a progress bar

```
image=retropie-4.5.1-rpi2_rpi3.img
block=/dev/sdb
test -b $block &&
sudo dd if=/dev/zero bs=1M count=1 of=$block &&
sudo sync &&
sleep 2 &&
sudo partprobe $block &&
sleep 2 &&
pv -cN "$image -> $block" $image | sudo dd bs=1M of=$block &&
sleep 2 &&
sudo sync
```

# Installed Image Work

* Grow / to 3.5G
* Upgrade installed packages

```
sudo resize2fs $(findmnt / -o source -n) 3500M &&
sudo apt update &&
sudo apt -y dist-upgrade &&
```

* Run RetroPie-Setup upgrade

```
cd $HOME/RetroPie-Setup
git pull
sudo ./retropie_setup.sh
```

* Clone RetroCRT
* Configure RetroCRT

```
cd $HOME
git clone https://github.com/xovox/RetroCRT
cd RetroCRT
./retrocrt_setup.sh
```

# Re-Running RetroCRT Playbook

```
eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")" &&
source ~/.virtualenv/retrocrt/bin/activate &&
ansible-playbook RetroCRT.yml -i localhost
```
