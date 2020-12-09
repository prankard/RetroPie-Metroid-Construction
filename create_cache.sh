ROOT_DIR="/opt/retropie/supplementary/metroid-construction/"

TODAY=$(date +'%Y-%m-%d')
#CACHE_FOLDER=/home/pi/metroidconstructionapi/cache_$TODAY
#ALL_CACHE_FOLDERS=/home/pi/metroidconstructionapi/cache_*
#TEMP_FOLDER=/home/pi/metroidconstructionapi/tmp
CACHE_FOLDER=/home/pi/.metroidconstruction/cache_$TODAY
ALL_CACHE_FOLDERS=/home/pi/.metroidconstruction/cache_*
TEMP_FOLDER=/home/pi/.metroidconstruction/tmp
TMP_HTML=$TEMP_FOLDER/id_info.txt
MENU_HTML=$CACHE_FOLDER/menu_source.html
MENU_DATA=$CACHE_FOLDER/menu_data.txt
MENU_DATA_DETAILED=$CACHE_FOLDER/menu_data_detailed.txt
TMP_ZIP=$TEMP_FOLDER/hack.zip
TMP_IPS=$TEMP_FOLDER/patch.ips

ROM_DIR=/home/pi/RetroPie/roms/snes
SOURCE_GAME=/home/pi/RetroPie/roms/snes/SuperMetroidOriginalHeaderless.smc.bak
MEDIA_DIR=/home/pi/RetroPie/roms/snes/media

#make dirs
#rm -r $TEMP_FOLDER
mkdir -p $TEMP_FOLDER

# Make new daily cache folder (and remove old)
if [ ! -d $CACHE_FOLDER ]; then
    rm -rf $ALL_CACHE_FOLDERS
    mkdir -p $CACHE_FOLDER
fi

#download html file
if [ ! -f $MENU_HTML ]; then
    wget "https://metroidconstruction.com/hacks.php?sort=&dir=&filters%5B%5D=M1&filters%5B%5D=M2&filters%5B%5D=SM&filters%5B%5D=MF&filters%5B%5D=MZM&filters%5B%5D=MP1&filters%5B%5D=MP2&filters%5B%5D=MP3&filters%5B%5D=Unknown&filters%5B%5D=Boss+Rush&filters%5B%5D=Exploration&filters%5B%5D=Challenge&filters%5B%5D=Spoof&filters%5B%5D=Speedrun%2FRace&filters%5B%5D=Incomplete&filters%5B%5D=Quick+Play&filters%5B%5D=Improvement&filters%5B%5D=Vanilla%2B&search=&num_per_page=1000&source=retropiescript" -O $MENU_HTML
fi

if [ ! -f $MENU_DATA ]; then
    python3 "$ROOT_DIR/parse_html_menu.py" $MENU_HTML $CACHE_FOLDER
fi
