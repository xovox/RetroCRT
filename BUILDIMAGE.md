# RetroPie Image Prep

* Download & decompress RetroPie image
* Append 250MB of blank space to end of image
* Setup loopback for RetroPie image
* Mount / & /boot in /tmp
* Disable resize-on-boot
* Enable ssh on boot
* Update config.txt

```
rpurl="https://github.com/RetroPie/RetroPie-Setup/releases/download/4.5.1/retropie-4.5.1-rpi2_rpi3.img.gz"
rpimage="$(basename "$rpurl" .gz)"
curl -L "$rpurl" | gunzip -c > $rpimage

sudo dd if=/dev/zero conv=notrunc oflag=append bs=1M count=500 of=$rpimage

loopback="$(sudo losetup -Pf --show $rpimage)"
bootpart=${loopback}p1
rootpart=${loopback}p2

sudo parted $loopback -- resizepart 2 100%
sudo partprobe
sudo e2fsck -f $rootpart
sudo resize2fs $rootpart

bootmnt="$(mktemp -d)"
rootmnt="$(mktemp -d)"
sudo mount $bootpart $bootmnt
sudo mount $rootpart $rootmnt

sudo sed -i.retrocrt '/END INIT INFO/a exit 0 # RetroCRT' $rootmnt/etc/init.d/resize2fs_once
sudo sed -i.retrocrt 's| init=/usr/lib/raspi-config/init_resize.sh||' $bootmnt/cmdline.txt
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

cat << CACHE | sudo dd of=$rootmnt/etc/apt/apt.conf.d/01-cache
Dir{Cache /dev/shm}
Dir::Cache /dev/shm;
Dir::Cache{Archives /dev/shm/}
Dir::Cache::Archives /dev/shm;
CACHE

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

* Run RetroPie-Setup upgrade

```
cd $HOME/RetroPie-Setup
git pull
sudo ./retropie_setup.sh
```

* Clone RetroCRT
* Configure RetroCRT
* Set splash screen

```
cd $HOME
git clone https://github.com/xovox/RetroCRT
cd RetroCRT
./retrocrt_setup.sh
echo $HOME/RetroPie/splashscreens/RetroCRT.mp4 | sudo tee /etc/splashscreen.list
```

# Re-Enable resizing on next boot

```
sudo sed -i 's|$| init=/usr/lib/raspi-config/init_resize.sh|' /boot/cmndline.txt
sudo sed -i '/RetroCRT/d' /etc/init.d/resize2fs_once
```

# Re-Running RetroCRT Playbook

```
cd $HOME/RetroCRT && 
git pull &&
eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")" &&
source ~/.virtualenv/retrocrt/bin/activate &&
ansible-playbook RetroCRT.yml -i localhost,
```
