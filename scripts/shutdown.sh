#!/bin/bash -x

#sudo /usr/bin/fbi --noonce -T 1 --noverbose -a -d /dev/fb0 -T 1 /home/pi/tmp.gif
sudo /usr/bin/fbi -T 2 -once -t 30 -noverbose -a /etc/RetroCRT.shutdown.png > /dev/null 2>&1 &
sleep 5
