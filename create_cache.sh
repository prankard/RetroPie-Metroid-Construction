ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"

TODAY=$(date +'%Y-%m-%d')
#CACHE_FOLDER=/home/pi/metroidconstructionapi/cache_$TODAY
#ALL_CACHE_FOLDERS=/home/pi/metroidconstructionapi/cache_*
#TEMP_FOLDER=/home/pi/metroidconstructionapi/tmp
ROOT_TEMP_FOLDER=/tmp/metroidconstruction
CACHE_FOLDER=$ROOT_TEMP_FOLDER/cache_$TODAY
ALL_CACHE_FOLDERS=$ROOT_TEMP_FOLDER/cache_*
TEMP_FOLDER=$ROOT_TEMP_FOLDER/tmp
TMP_HTML=$TEMP_FOLDER/id_info.txt
MENU_HTML=$CACHE_FOLDER/menu_source.html
MENU_DATA_EXAMPLE=$CACHE_FOLDER/SM_menu_data.txt
TMP_ZIP=$TEMP_FOLDER/hack.zip
TMP_IPS=$TEMP_FOLDER/patch.ips

#make dirs

if [[ ! -d "$ROOT_TEMP_FOLDER" ]]; then
    mkdir "$ROOT_TEMP_FOLDER"
    chmod 777 "$ROOT_TEMP_FOLDER"
fi

#rm -r $TEMP_FOLDER
if [[ ! -d "$TEMP_FOLDER" ]]; then
    echo "Creating temp folder"
    mkdir "$TEMP_FOLDER"
    chmod 777 "$TEMP_FOLDER"
fi

# Make new daily cache folder (and remove old)
if [ ! -d $CACHE_FOLDER ]; then
    echo "Creating cache folder"
    rm -rf "$ALL_CACHE_FOLDERS"
    mkdir "$CACHE_FOLDER"
    chmod 777 "$CACHE_FOLDER"
fi

#download html file
if [ ! -f $MENU_HTML ]; then
    wget "https://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=1000&source=retropiescript" -O $MENU_HTML
fi

if [ ! -f $MENU_DATA_EXAMPLE ]; then
    python3 "$ROOT_DIR/parse_html_menu.py" $MENU_HTML $CACHE_FOLDER
fi
