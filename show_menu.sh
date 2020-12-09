#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$DIR/functions.sh"

bash "$DIR/create_cache.sh"
GAME=SM

# Game Selection
if [ -z $1 ]; then
    configure_options=("M1" "Metroid 1" "M2" "Metroid 2" "SM" "Super Metroid" "MF" "Metroid Fusion" "MZM" "Metroid Zero Mission" "A" "Advanced Settings")
    cmd=(dialog --title "  Metroid Construction  " --colors --menu "\nMetroid Construction is a home for homebrew hacks. Please visit www.metroidconstruciton.com for reviews, screenshots, installation details and post your opinions for the homebrew content you play\n" 19 80 12)
    game_choice=$("${cmd[@]}" "${configure_options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$game_choice" ]]; then
        GAME=$game_choice
    else
        clear
        exit
    fi
else
    GAME=$1
fi

GAME_SYSTEM=$(eval getSystemFromGame "$GAME")
GAMELIST_PATH=$(eval getGamelistPath "$GAME_SYSTEM")

TODAY=$(date +'%Y-%m-%d')
CACHE_FOLDER=/home/pi/metroidconstructionapi/cache_$TODAY
TEMP_FOLDER=/home/pi/metroidconstructionapi/tmp
MENU_HTML=$CACHE_FOLDER/menu_source.html
MENU_DATA=$CACHE_FOLDER/${GAME}_menu_data.txt
MENU_DATA_DETAILED=$CACHE_FOLDER/${GAME}_menu_data_detailed.txt
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
    exec "$DIR/show_menu.sh"
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
    menu_text+="Installed:    \Z2Yes\n\n"
else
    menu_text+="Installed:    \Z1No\n\n"
fi

configure_options=("I" "Install" "U" "Uninstall" "B" "Back")
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
        bash download_patch.sh "$GAME" "$choice" "$hack_name" "$hack_author" "$hack_genre" "$hack_date" "$hack_rating"
        exec "$DIR/show_menu.sh" $GAME
    elif [ "$install_choice" = "U" ]; then
        echo "We now remove files"
        echo "rm -f "$hack_files"*"
        rm -f "$hack_files"*
        python3 modify_gamelist.py $GAMELIST_PATH remove $hack_id
        exec "$DIR/show_menu.sh" $GAME
    else
        exec "$DIR/show_menu.sh" $GAME
    fi
else
    exec "$DIR/show_menu.sh" $GAME
fi