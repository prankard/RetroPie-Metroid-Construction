#!/bin/bash
ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"
source "$ROOT_DIR/functions.sh"


bash "$ROOT_DIR/create_cache.sh"
if [ -z "$(hasAnySourceRoms)" ]; then
    dialog --title "  NO SOURCE FILES YET  " --colors --msgbox "\nNo source roms found, please check the advanced settings to select source roms for the metroid games homebrew you'd like to install" 19 80
fi

bash $ROOT_DIR/show_menu.sh