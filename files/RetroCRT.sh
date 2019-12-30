#!/bin/bash

eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"

cd $retrocrt_install

sudo -u pi ./retrocrt_setup.sh
