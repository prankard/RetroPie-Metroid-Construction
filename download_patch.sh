#!/bin/bash
ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"

source "$ROOT_DIR/functions.sh"

# TODO display list of hacks
# TODO handle rar files https://metroidconstruction.com/hack.php?id=294 https://metroidconstruction.com/hack.php?id=33
# TODO handle 7z files https://metroidconstruction.com/hack.php?id=365
# TODO handle multiple download links (https://metroidconstruction.com/hack.php?id=294)
# TODO handle multiple ips in zips
# TODO, choose multiple ips options in zip https://metroidconstruction.com/hack.php?id=87
# TODO, overlay IPS patches (really!!!) https://metroidconstruction.com/hack.php?id=87


# variables
if [ -z "$1" ]; then
    GAME="SM"
else
    GAME=$1
fi

#GAME="SM"
GAME_SYSTEM=$(eval getSystemFromGame "$GAME")
GAMELIST_PATH=$(eval getGamelistPath "$GAME_SYSTEM")

echo $GAME
echo $GAME_SYSTEM
echo $GAMELIST_PATH
#sleep 5
#exit

if [ $2 -eq 0 ]; then
    number_input=$(getnumberinput)
else
    number_input=$2
fi

hack_id=$number_input
echo "HackID:"$hack_id

if [ "$hack_id" -eq 0 ]; then
    exit
fi

GAME_HTML=${CACHE_FOLDER}/${hack_id}.html
TMP_GAME_VARS=$TEMP_FOLDER/game.ini
TMP_IPS=$TEMP_FOLDER/patch.ips
TMP_LIST=$TEMP_FOLDER/list.txt

ROM_DIR=$(eval getRetropiePath)/roms/${GAME_SYSTEM}
#SOURCE_GAME=/home/pi/RetroPie/roms/snes/SuperMetroidOriginalHeaderless.smc.bak
SOURCE_GAME=$(eval getSourceGamePath "$GAME")
MEDIA_DIR=$(eval getMediaPath "$GAME_SYSTEM")

#make dirs
#rm -r $TEMP_FOLDER
mkdir -p $TEMP_FOLDER

#download html file
if [ ! -f $GAME_HTML ]; then
    wget https://metroidconstruction.com/hack.php?id=$hack_id -O $GAME_HTML
fi

#parse html into variables
rm -f $TMP_GAME_VARS
python3 "$ROOT_DIR/parse_html_game.py" $GAME_HTML $TMP_GAME_VARS
source $TMP_GAME_VARS

echo "Images: "$hack_image
echo "Download: "$hack_download
echo "Download: "$hack_downloads

IFS=',' read -r -a hack_downloads_array <<< "$hack_downloads"
if [ ${#hack_downloads_array[@]} -gt 1 ]; then
    # So much download choice, let's refine
    options=()
    for i in "${!hack_downloads_array[@]}"
    do
        download_filename=$(basename -- "${hack_downloads_array[$i]}")
        download_filename=$(echo $download_filename | cut -f1 -d "?") # strip php arguments
        options+=("$i" "${download_filename}")
        # or do whatever with individual element of the array
    done
    #sleep 5
    cmd=(dialog --title " Choose Download " --no-tags --menu "Please select download option\nIf you are in doubt between headered/unheadered, choose the unheadered option" 19 80 12)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        echo $choice
        hack_download="${hack_downloads_array[$choice]}"
        echo $hack_download
        #sleep 10
        #echo "unzip -p "$TMP_ZIP" "$choice" > "$TMP_IPS""
        #unzip -p "$TMP_ZIP" "$choice" > "$TMP_IPS"
        #echo $choice
    else
        echo "Ok, cancelled"
        exit
    fi
fi

echo "Description: "$hack_desc

# TODO: Chooce hack file if it's more than one download
DOWNLOAD_LINK=$hack_download
DOWNLOAD_LINK=$(echo $hack_download | cut -f1 -d "?") # strip php arguments
#DOWNLOAD_LINK=$(echo "$DOWNLOAD_LINK" | tr + ' ')
#DOWNLOAD_LINK=$(echo $hack_download | cut -f1 -d "?") # strip php arguments
echo "Download link: "$DOWNLOAD_LINK

#sleep 5
#exit
#sleep 10
#exit
#DOWNLOAD_LINK=https://metroidconstruction.com//files/hacks/441/Rogue_Dawn_V121.zip

#check file is zip
full_filename=$(basename -- "$DOWNLOAD_LINK")
full_filename=$(echo $full_filename | cut -f1 -d "?") # strip php arguments

DOWNLOAD_LINK=$(echo "$DOWNLOAD_LINK" | sed -e "s/+/%20/g") # Replace + with %20 for download links (to download right file, but don't do it to filename above)

extension="${full_filename##*.}"
extension=${extension,,} #to lowercase
filename="${full_filename%.*}"

echo $full_filename
echo $filename
echo $extension
TMP_ARCHIVE=$TEMP_FOLDER/hack.$extension

if [ "$extension" = "rar" ]; then
    if [ ! -f $TMP_ARCHIVE ]; then
        wget $DOWNLOAD_LINK -O $TMP_ARCHIVE
    fi
    echo "Extract .rar here"

    unrar-free -t $TMP_ARCHIVE | grep -i '.ips' | cut -c 2- > $TMP_LIST
    choice=$(eval chooseOneOption "\"$TMP_LIST\"" "\" AChoose IPS \"" "\"APlease select and IPS file to patch\"")
    if [ ! -z "$choice" ]; then
        echo "Choice was not empty"
        echo "You choose: "$choice
        cd $TEMP_FOLDER
        unrar-free -x --extract-no-paths "$TMP_ARCHIVE" "$choice"
        choice_filename=$(basename -- "$choice") #get filename
        echo "unrar-free -x --extract-no-paths \"$TMP_ARCHIVE\" \"$choice\""
        mv "${TEMP_FOLDER}/${choice_filename}" "${TMP_IPS}"
        cd "../"
    else
        exit
    fi
elif [ "$extension" = "zip" ] || [ "$extension" = "7z" ]; then
    #list ips in zip line by line
    if [ ! -f $TMP_ARCHIVE ]; then
        wget $DOWNLOAD_LINK -O $TMP_ARCHIVE
    fi
    #ips_files=$(unzip -l $TMP_ARCHIVE | grep -i '.ips' | cut -c 31-) # old unzip list
    7z l $TMP_ARCHIVE | grep -i '.ips' | cut -c 54- > $TMP_LIST 
    choice=$(eval chooseOneOption "\"$TMP_LIST\"" "\" AChoose IPS \"" "\"APlease select and IPS file to patch\"")
    if [ ! -z "$choice" ]; then
        #unzip -p "$TMP_ARCHIVE" "$ips_files" > "$TMP_IPS" # old unzip
        cd $TEMP_FOLDER
        7z e "$TMP_ARCHIVE" "$choice"
        choice_filename=$(basename -- "$choice") #get filename
        mv "${TEMP_FOLDER}/${choice_filename}" "${TMP_IPS}"
        cd "$ROOT_DIR"
    else
        exit
    fi
elif [ "$extension" = "ips" ]; then
    if [ ! -f $TMP_IPS ]; then
        wget $DOWNLOAD_LINK -O $TMP_IPS
    fi
else
    echo "File extension: " . $extension . "not supported"
    sleep 2
    exit
fi


#put ips and original file in rom folder

# Check overwriting files
DESTINATION_IPS=${ROM_DIR}/metcon_${hack_id}_${filename}.ips
DESTINATION_SMC=$ROM_DIR/metcon_${hack_id}_$filename.smc
DESTINATION_SMC_FILENAME=metcon_${hack_id}_$filename.smc
if test -e $DESTINATION_IPS || test -e $DESTINATION_SMC; then
    yesno=$(areyousure "$filename already exists, overwrite?")
    if [ "$yesno" -eq 1 ]; then
        rm -f $DESTINATION_IPS
        rm -f $DESTINATION_SMC
    else
        exit
    fi
fi

#move ips file (move later, copy for now)
mv $TMP_IPS $DESTINATION_IPS
#copy source game
cp $SOURCE_GAME $DESTINATION_SMC

echo $DESTINATION_IPS
echo $DESTINATION_SMC
echo "Please restart emulation station from the start menu"

#sleep 3
#clear

#add description to gamelist file

#addGameToXML "snes" "Super Metroid Test" "./testromnew.smc" "new description a a a a" "Super Metroid"

echo "Download: "$hack_download
echo "Description: "$hack_desc

#menu_text+="Title:        $hack_name\n"
#menu_text+="Author:       $hack_author\n"
#menu_text+="Genre:        $hack_genre\n"
#menu_text+="Date Created: $hack_date\n"
#menu_text+="Avg Rating:   $hack_rating\n\n"


hack_name="$3"
hack_author="$4"
hack_genre="$5"
hack_datetime="$6"
hack_rating_percent="$7"

# Parse game arguments
image_extension=$(basename -- "$hack_image") #get filename
image_extension=$(echo $image_extension | cut -f1 -d "?") # strip php arguments
image_extension="${image_extension##*.}" # get extension
image_extension=${image_extension,,} #to lowercase
local_image_filename=./$hack_id.$image_extension

echo "Downloading screenshot"
wget $hack_image -O $MEDIA_DIR/$local_image_filename
python3 "$ROOT_DIR/modify_gamelist.py" "$GAMELIST_PATH" add "$hack_id" "$hack_name" "$DESTINATION_SMC_FILENAME" "$hack_rating_percent" "$hack_datetime" "$hack_author" "$hack_genre" "$local_image_filename" "$hack_desc"

#addGameToXML "snes" "Super Metroid Randomized" "$DESTINATION_SMC_FILENAME" "$DESC" "Super Metroid"

#cleanup remove temp
#rm -r $TEMP_FOLDER

