#!/bin/bash
ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"
source "$ROOT_DIR/data.ini"

function getRetropiePath()
{
    echo "$(find /home -type d -name RetroPie -print -quit 2> /dev/null)"
}

function getGames()
{
    echo $GAMES_LIST
}

function getSystemFromGame()
{
    if [ -z "$GAME_TO_SYSTEMS_ARRAY" ]; then
        IFS=',' read -r -a GAME_TO_SYSTEMS_ARRAY <<< "$GAME_TO_SYSTEMS"
    fi

    for (( c=0; c<=${#GAME_TO_SYSTEMS_ARRAY[@]}; c+=2 ))
    do  
        if [ "$1" = "${GAME_TO_SYSTEMS_ARRAY[$c]}" ]; then
            echo ${GAME_TO_SYSTEMS_ARRAY[$c+1]}
        fi
    done
}

function getSourceGamePath()
{
    if [ -z "$GAME_TO_SOURCE_FILES_ARRAY" ]; then
        IFS=',' read -r -a GAME_TO_SOURCE_FILES_ARRAY <<< "$GAME_TO_SOURCE_FILES"
    fi

    for (( c=0; c<=${#GAME_TO_SOURCE_FILES_ARRAY[@]}; c+=2 ))
    do  
        if [ "$1" = "${GAME_TO_SOURCE_FILES_ARRAY[$c]}" ]; then
            echo ${GAME_TO_SOURCE_FILES_ARRAY[$c+1]}
        fi
    done
}

function getMd5FromGame()
{
    if [ -z "$GAME_TO_MD5_ARRAY" ]; then
        IFS=',' read -r -a GAME_TO_MD5_ARRAY <<< "$GAME_TO_MD5"
    fi

    for (( c=0; c<=${#GAME_TO_MD5_ARRAY[@]}; c+=2 ))
    do  
        if [ "$1" = "${GAME_TO_MD5_ARRAY[$c]}" ]; then
            echo ${GAME_TO_MD5_ARRAY[$c+1]}
        fi
    done
}

###################################################
# getGamelistPath
#
# Globals:
#   None
#
# Arguments:
#   $1 Rom Folder System    (eg. snes)
#
# Returns:
#   "/home/pi/gamelistPath.xml" or ""
#
function getGamelistPath()
{
    local home="$(find /home -type d -name RetroPie -print -quit 2> /dev/null)"
    local gamelistPath="$home/roms/$1/gamelist.xml"
    if [[ ! -f "$gamelistPath" ]]; then
        local gamelistPath="$home/../.emulationstation/gamelists/$1/gamelist.xml"
        if [[ ! -f "$gamelistPath" ]]; then
            local gamelistPath=""
        fi
    fi
    echo $gamelistPath
}

function getMediaPath()
{
    local home="$(find /home -type d -name RetroPie -print -quit 2> /dev/null)"
    echo "$home/roms/$1/media/images"
}

#Functions
function getnumberinput
{
    local menu_text=("Select the first digit" "Select the second digit" "Select the third digit")
    local options=()
    local number_input=
    #options=("Option 1" "Option 2" "Option 3" "Number 4" "Number 5" "Number 6" "Number 7" "Number 8" "Number 9" "Number 10")
    for i in {0..10}
    do
        options+=("$i" "Number $i")
    done


    for i in "${!menu_text[@]}"; do
        local cmd=(dialog --title " Generate Rom " --menu "${menu_text[i]}" 19 80 12)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            number_input=$number_input$choice
            #echo $choice
        else
            number_input=0
            echo $number_input
            exit
        fi
    done

    echo $number_input
}

function areyousure
{
    local cmd=(dialog --title " Are you sure? " --menu "$1" 19 80 12)
    local options=("0" "No" "1" "Yes")
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ "$choice" -eq 1 ]]; then
        echo 1
    else
        echo 0
    fi
}

function showpopup
{
    #local cmd=(dialog --title " $1 " --menu "$1" 19 80 12)
    #local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) 
    echo "show popup $1"
}

function getdownloadurlfromhtml
{
    local GREP1=$(grep -o '<b>Download:</b>.*</a>' $TMP_HTML)
    #<b>Download</b> <a href="download.php?id=410&f=https%3A%2F%2Fmetroidconstruction.com%2F%2Ffiles%2Fhacks%2F410%2FSM_Ascent_1.12.zip">Version 1.12 Unheadered</a>
    #echo $GREP1
    local GREP2=$(grep -o '&f=.*">' <<< "$GREP1")
    #echo $GREP2
    # 
    #echo $(awk '{if (NR!=1) {print substr($2, 1, length($2)-1)}}' <<< $GREP2)
    #echo $(cut -c4- <<< $GREP2)
    local GREP3=$(sed -e 's/&f=\(.*\)">/\1/' <<< $GREP2)
    #echo $GREP3
    local RESULT=$(urldecode "$GREP3")
    #return $RESULT
    echo $RESULT
}

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }


# This function did not work, newlines are hard to pass as parameters, more thought needed
## Returns empty string if cancelled
## Returns single option if sucessful
## Takes a newline list of options file
function chooseOneOption()
{
    local ips_files_count=$(wc -l < $1)
    #echo $ips_files_count
    if [ "$ips_files_count" -eq 0 ]; then
        #echo "No ips files found in downloaded zip"
        echo ""
    elif [ "$ips_files_count" -eq 1 ]; then
        #echo  "we found one result"
        echo $(head -n 1 $1)
    else
        #echo "we have multiple options please pick one"
        local options=()
        while read -r line
        do
            local options+=("$line" "$line")
            #echo "$line"
        done < $1
        
        #sleep 5
        local cmd=(dialog --title "$2" --no-tags --menu "$3" 19 80 12)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        echo $choice
    fi
}