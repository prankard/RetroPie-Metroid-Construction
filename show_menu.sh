#!/bin/bash
ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"
GAME=SM

source "$ROOT_DIR/functions.sh"

#function 
function show_advanced_menu()
{
    local options=("S" "Select Source ROM Files from RetroPie" "V" "Verify All Valid Source ROM Files" "D" "Delete ALL Metroid Construction Hacks" "B" "Back")
    local cmd=(dialog --title "  Advanced Settings  " --colors --menu "\nAll the advanced stuff is in here, be careful\n" 19 80 12)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    
    if [[ -n "$choice" ]]; then
        if [ "$choice" = "S" ]; then
            local game_choice=$(chooseAGame)
            if [ ! -z "$game_choice" ]; then
                local game_system=$(eval getSystemFromGame "$game_choice")
                local rom_folder=$(eval getRetropiePath)/roms/${game_system}/
                dialog --title "  Select code  " --colors --msgbox "Here we select a rom for $game_choice in folder:\n$rom_folder\n" 19 80
            fi
        elif [ "$choice" = "V" ]; then
            bash "$ROOT_DIR/verify_installed_files.sh"
        elif [ "$choice" = "D" ]; then
                local you_sure=$(areyousure "\nAre you sure, this will delete all hacks installed by this plugin, and ALL their battery save files")
            if [ "$you_sure" = "1" ]; then
                local you_really_sure=$(areyousure "\nAre you really sure?\nThere is no turning back after this point\n")
                if [ "$you_really_sure" = "1" ]; then
                    dialog --title "  WELL, THERE IS NO TURNING BACK NOW  " --colors --msgbox "\nWe just removed all your files.\nConsider this a fresh start :)\n" 19 80
                fi
            fi
        else
            exec "$ROOT_DIR/show_menu.sh"
        fi
        exec "$ROOT_DIR/show_menu.sh" "A"
    else
        exec "$ROOT_DIR/show_menu.sh"
    fi
}

# Game Selection
if [ -z $1 ]; then
    bash "$ROOT_DIR/create_cache.sh"

    configure_options=()
    for GAME in "${GAMES_ARRAY[@]}"
    do
        GAME_NAME=$(getNameFromGame "${GAME}")
        configure_options+=("$GAME" "$GAME_NAME")
    done
    configure_options+=("A" "Advanced Settings")
    cmd=(dialog --title "  Metroid Construction  " --colors --menu "\nMetroid Construction is a home for homebrew hacks. Please visit www.metroidconstruciton.com for reviews, screenshots, installation details and post your opinions for the homebrew content you play\n" 19 80 12)
    game_choice=$("${cmd[@]}" "${configure_options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$game_choice" ]]; then
        if [ "$game_choice" = "A" ]; then
            show_advanced_menu
#           echo "We should do advanced options now"
            exit
        else
            GAME=$game_choice
            if [[ ! -f "$(eval getSourceGamePath $GAME)" ]]; then
                dialog --title "  ROM NOT FOUND:  " --colors --msgbox "\nWarning, ROM file not found at path:\n$(eval getSourceGamePath $GAME)\n\nYou can browse packages, but they cannot be installed" 19 80
                unset HAS_FILE
            else
                HAS_FILE=1
            fi
        fi
    else
        clear
        exit
    fi
else
    if [ "$1" == "A" ]; then
        show_advanced_menu
    else
        GAME=$1
    fi
fi

GAME_SYSTEM=$(eval getSystemFromGame "$GAME")
GAMELIST_PATH=$(eval getGamelistPath "$GAME_SYSTEM")

SEPERATOR="|||"
ROM_DIR=$(eval getRetropiePath)/roms/${GAME_SYSTEM}/

# Package Selection
mapfile -t options < $MENU_DATA
#dialog --title " Menu! " --column-separator "|" --menu "" 19 40 12 "1" "A long option|One" "2" "Option|Two" "3" "Option|Three" "4" "Option|Four"
#dialog --title " Menu! " --column-separator "|" --menu "" 19 40 12
cmd=(dialog --title "  Metroid Construction  " --column-separator "$SEPERATOR" --menu "\nSelect Hack to Configure\n" 19 80 12)
choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
if [[ -n "$choice" ]]; then
    echo $choice
else
    exec "$ROOT_DIR/show_menu.sh"
fi
#echo $choice

# Read game selection
while IFS= read -r line
do
    hack_id="$(cut -d'|' -f1 <<<"$line")"
    if [ "$hack_id" = "$choice" ]; then
        mapfile -t array < <( echo "${line//|||/$'\n'}" )
        hack_id="${array[0]}" #id
        hack_name="${array[1]}" #name
        hack_author="${array[2]}" #author
        hack_genre="${array[3]}" #genre
        hack_game="${array[4]}" #gameid
        hack_date="${array[5]}" #date
        hack_completion="${array[6]}" #completion time
        hack_rating="${array[7]}" #rating
        break
    fi
done < "$MENU_DATA_DETAILED"


# Check overwriting files
#DESTINATION_IPS=${ROM_DIR}/metcon_${hack_id}_${filename}.ips
#DESTINATION_SMC=$ROM_DIR/metcon_${hack_id}_$filename.smc
#DESTINATION_SMC_FILENAME=metcon_${hack_id}_$filename.smc
#if test -e $DESTINATION_IPS || test -e $DESTINATION_SMC; then
#    yesno=$(areyousure "$filename already exists, overwrite?")
#    if [ "$yesno" -eq 1 ]; then
#        rm -f $DESTINATION_IPS
#        rm -f $DESTINATION_SMC
#    else
#        exit
#    fi
#fi
menu_text="\n"
menu_text+="Title:        $hack_name\n"
menu_text+="Author:       $hack_author\n"
menu_text+="Genre:        $hack_genre\n"
menu_text+="Game:         $hack_game\n"
menu_text+="Date Created: $hack_date\n"
menu_text+="Avg Time:     $hack_completion\n"
menu_text+="Avg Rating:   $hack_rating\n\n"
hack_files=${ROM_DIR}metcon_${hack_id}_

if compgen -G "${hack_files}*" > /dev/null; then
    HAS_INSTALLED=1
    menu_text+="Installed:    \Z2Yes\n\n"
else
    unset HAS_INSTALLED
    menu_text+="Installed:    \Z1No\n\n"
fi

configure_options=()
if [ ! -z "$HAS_FILE" ]; then
    if [ ! -z "$HAS_INSTALLLED" ]; then
        configure_options+=("I" "Install")
    else
        configure_options+=("U" "Uninstall")
    fi
fi
configure_options+=("B" "Back")
cmd=(dialog --title "  $hack_name  " --colors --menu "$menu_text" 19 80 12)
install_choice=$("${cmd[@]}" "${configure_options[@]}" 2>&1 >/dev/tty)

echo $menu_text
#clear

#mapfile -t options < $MENU_DATA

#cmd=(dialog --title "  Metroid Construction  " --menu "Hey" 19 80 12)
#mapfile -t options < $MENU_DATA
#choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

if [[ -n "$install_choice" ]]; then
    if [ "$install_choice" = "I" ]; then
        "$ROOT_DIR/download_patch.sh" "$GAME" "$choice" "$hack_name" "$hack_author" "$hack_genre" "$hack_date" "$hack_rating"
        exec "$ROOT_DIR/show_menu.sh" $GAME
    elif [ "$install_choice" = "U" ]; then
        echo "We now remove files"
        echo "rm -f "$hack_files"*"
        rm -f "$hack_files"*
        python3 "$ROOT_DIR/modify_gamelist.py" "$GAMELIST_PATH" remove $hack_id
        exec "$ROOT_DIR/show_menu.sh" $GAME
    else
        exec "$ROOT_DIR/show_menu.sh" $GAME
    fi
else
    exec "$ROOT_DIR/show_menu.sh" $GAME
fi