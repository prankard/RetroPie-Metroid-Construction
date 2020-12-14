#!/bin/bash
ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"
source "$ROOT_DIR/functions.sh"


bash "$ROOT_DIR/create_cache.sh"
if [ -z "$(hasAnySourceRoms)" ]; then
    dialog --title "  NO SOURCE FILES YET  " --colors --msgbox "\nNo source roms found, please check the advanced settings to select source roms for the metroid games homebrew you'd like to install" 19 80
fi

bash $ROOT_DIR/show_menu.sh
# Show Test dialog
#options=("1" "Yes" "2" "No")
#cmd=(dialog --title " Did this work " --menu "Is this menu showing up on your screen?" 19 80 12)
#choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
#echo $choice
#sleep 1