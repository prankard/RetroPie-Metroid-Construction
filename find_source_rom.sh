#!/bin/bash

ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"
source "$ROOT_DIR/functions.sh"

rom_folder="$1"
TMP_LIST=$TEMP_FOLDER/list.txt
destination_file="$2"
extensions_list="$3"

echo "Looking for: $rom_folder"
echo "Destination File: $destination_file"
echo "Extensions List: $extension_lists"
sleep 5
exit

local game_system=$(eval getSystemFromGame "$game_choice")
local rom_folder=$(eval getRetropiePath)/roms/${game_system}/
local TMP_LIST=$TEMP_FOLDER/list.txt
find "$rom_folder" -name '*.smc' -o -name '*.sfc' -o -name '*.zip' > $TMP_LIST
local chosen_file_path=$(eval chooseOneOption "\"$TMP_LIST\"" "\" A Choose ROM \"" "\"\nPlease Select an source UNHEADERED rom file to use to patch homebrew\n\nThis will be the base file that all hacks will be patched from\n\"")
local destination_file=$(eval getSourceGamePath "$game_choice")
if [ ! -z "$chosen_file_path" ]; then
    local extension="${chosen_file_path##*.}"
    local extension=${extension,,} #to lowercase
    if [ "$extension" = "zip" ]; then
        #dialog --title "  Oh noes  " --colors --msgbox "Oh now, we can't do zip just yet:\n$chosen_file_path\n" 19 80
        #todo, find a way to do multiple file types
        7z l "$chosen_file_path" | grep -i '.smc' | cut -c 54- > $TMP_LIST 
        local zip_choice=$(eval chooseOneOption "\"$TMP_LIST\"" "\" Choose a source file \"" "\"Please select and source file to patch\"")
        if [ ! -z "$zip_choice" ]; then
            #unzip -p "$TMP_ARCHIVE" "$ips_files" > "$TMP_IPS" # old unzip
            cd $TEMP_FOLDER
            7z e "$chosen_file_path" "$zip_choice"
            local choice_filename=$(basename -- "$zip_choice") #get filename
            mv "${TEMP_FOLDER}/${choice_filename}" "${destination_file}"
            cd "$ROOT_DIR"
        else
            exec "$ROOT_DIR/show_menu.sh" "A"
        fi

    else
        local valid_md5_hash=$(getMd5FromGame "${game_choice}")
        local hash=($(md5sum "$chosen_file_path"))
        if [ "$hash" = "$valid_md5_hash" ]; then
            local destination_folder="$(dirname "${destination_file}")"
            local source_filename="$(basename "${chosen_file_path}")"
            mkdir -p "$destination_folder"
            cp "$chosen_file_path" "$destination_folder"
            mv "$destination_folder/$source_filename" "$destination_file"
            bash "$ROOT_DIR/verify_installed_files.sh"
            #dialog --title "  VALID FILE  " --colors --msgbox "\nValid file copied to $destination_file\n\nThank you :)" 19 80
        else
            dialog --title "  INVALID FILE  " --colors --msgbox "\nInvalid file at $chosen_file_path\n\nWanted Md5 hash: $valid_md5_hash\nYour Md5 hash: $hash" 19 80
        fi
    fi
fi