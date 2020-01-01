export runcommand_onend_log="/dev/shm/runcommand-onend.log"
(
set -x
eval "$(dos2unix < "/boot/retrocrt/retrocrt.txt")"
export rpie_onend_script_dir="$retrocrt_install/scripts/runcommand-onend.d"
for rpie_onend_script in $rpie_onend_script_dir/*.{sh,pl,py} ; do
    if [ -f "$rpie_onend_script" ]; then
        echo "##############################################################################"
        echo "$rpie_onend_script"
        echo "##############################################################################"
        $rpie_onend_script "$1" "$2" "$3" "$4"
    fi
done
set +x
) > $runcommand_onend_log 2>&1
