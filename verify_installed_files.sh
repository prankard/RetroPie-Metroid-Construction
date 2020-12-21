#!/bin/bash
ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"

source "$ROOT_DIR/functions.sh"
#GAMES_ARRAY=("M1" "M2" "SM" "MF" "MZM")

MSG="\nTesting current ROM files for the correct unheadered versions used with this plugin\n\n\n"

for GAME in "${GAMES_ARRAY[@]}"
do
    GAME_PATH=$(getSourceGamePath "${GAME}")
    MSG+="\Z0  ${GAME}: "
    if [[ -f $GAME_PATH ]]; then
        VALID_MD5_HASH=$(getMd5FromGame "${GAME}")
        HASH=($(md5sum "$GAME_PATH"))
        if [ "$HASH" = "$VALID_MD5_HASH" ]; then
            MSG+="\Z2Valid MD5\n\n"
        else
            MSG+="\Z1Invalid MD5 Checksum\n\Z4${GAME_PATH}\n"
        fi
    else
        MSG+="\Z1File not found\n\Z4${GAME_PATH}\n"
    fi
done

dialog --title "  CHECKING SOURCE ROMS  " --colors --msgbox "$MSG" 19 80