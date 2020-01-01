(
set -x
export rpie_onend_script_dir="$HOME/scripts/runcommand-onend.d"
export runcommand_onend_log="/dev/shm/runcommand-onend.log"
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
