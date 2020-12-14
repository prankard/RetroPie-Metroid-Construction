#!/bin/bash

ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"
source "$ROOT_DIR/functions.sh"
mkdir -p $TEMP_FOLDER
TMP_LIST=$TEMP_FOLDER/list.txt
#sleep 5
#exit
#local game_system=$(eval getSystemFromGame "$game_choice")
function find_source()
{
    local rom_folder="$1"
    local destination_file="$2"
    local extensions_list="$3"
    local valid_hash="$4"
    #echo "Looking for: $rom_folder"
    #echo "Destination File: $destination_file"
    #echo "Extensions List: $extensions_list"


    #find "$rom_folder" -name '*.smc' -o -name '*.sfc' -o -name '*.zip' > $TMP_LIST
    #TODO make grep work with full paths, at teh oment it's lcoal path with the new patch
    ls "$rom_folder" | grep -E "$extensions_list" > $TMP_LIST
    local chosen_file_path=$(eval chooseOneOption "\"$TMP_LIST\"" "\" A Choose ROM \"" "\"\nPlease Select an source UNHEADERED rom file to use to patch homebrew\n\nThis will be the base file that all hacks will be patched from\n\"")
    chosen_file_path=$rom_folder/$chosen_file_path
    local destination_file=$(eval getSourceGamePath "$game_choice")
    if [ ! -z "$chosen_file_path" ]; then
        local extension="${chosen_file_path##*.}"
        local extension=${extension,,} #to lowercase
        if [ "$extension" = "zip" ]; then
            #dialog --title "  Oh noes  " --colors --msgbox "Oh now, we can't do zip just yet:\n$chosen_file_path\n" 19 80
            #todo, find a way to do multiple file types
            7z l "$chosen_file_path" | grep -i '$extensions_list' | cut -c 54- > $TMP_LIST 
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
            local destination_folder="$(dirname "${destination_file}")"
            local source_filename="$(basename "${chosen_file_path}")"
            mkdir -p "$destination_folder"
            cp "$chosen_file_path" "$destination_folder"
            mv "$destination_folder/$source_filename" "$destination_file"
        fi

        if [ -f "$destination_file" ]; then
            local hash=($(md5sum "$destination_file"))
            if [ "$hash" = "$valid_hash" ]; then
                bash "$ROOT_DIR/verify_installed_files.sh"
                #dialog --title "  VALID FILE  " --colors --msgbox "\nValid file copied to $destination_file\n\nThank you :)" 19 80
            else
                rm -f "$destination_file"
                dialog --title "  INVALID FILE  " --colors --msgbox "\nInvalid file at $chosen_file_path\n\nWanted Md5 hash: $valid_md5_hash\nYour Md5 hash: $hash" 19 80
            fi
        else
            dialog --title "  COULD NOT COPY FILE  " --msgbox "\nCould not copy file to: ${destination_file}\n\n" 19 80
        fi
    fi
        
}

echo "About to find source"
sleep 3
find_source "$1" "$2" "$3"
sleep 3
