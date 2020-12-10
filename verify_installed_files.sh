#!/bin/bash
ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"

source "$ROOT_DIR/functions.sh"
GAMES_ARRAY=("M1", "M2", "SM", "MF", "MZM")

for (( c=0; c<=${#GAMES_ARRAY[@]}; c+=1 ))
do  
    VALID_MD5_HASH=$(eval getSystemFromGame "${GAMES_ARRAY[$c]}")
    PATH=$(eval getSourceGamePath "${GAMES_ARRAY[$c]}")
    HASH=$(eval md5sum $PATH | awk {' print $1 '})
    if [ "$HASH" = "$VALID_MD5_HASH" ]
        echo "Valid hash for: $path"
    else
        echo "Invalid hash for: $path"
    fi
done