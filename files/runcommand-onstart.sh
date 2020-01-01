export runcommand_onstart_log="/dev/shm/retrocrt-onstart.log"
(
set -x
eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"

export rpie_onstart_script_dir="$retrocrt_install/scripts/runcommand-onstart.d"
export ra_system="$1"
export ra_emulator="$2"
export ra_rom="$3"
export ra_command="$4"

export ra_rom_stripped="${ra_rom%.*}"
export ra_rom_basename="$(basename "$ra_rom_stripped")"

for rpie_onstart_script in $rpie_onstart_script_dir/*.{sh,pl,py} ; do
    if [ -f "$rpie_onstart_script" ]; then
        echo "##############################################################################"
        echo "$rpie_onstart_script"
        echo "##############################################################################"
        $rpie_onstart_script "$1" "$2" "$3" "$4"
    fi
done
set +x
) > $runcommand_onstart_log 2>&1
