#!/bin/bash
readonly LOCAL_PATH="/home/pi/Projects/RetroPie-Metroid-Construction"

user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"
home="$(eval echo ~$user)"
#readonly REPO_PATH="https://raw.githubusercontent.com/prankard/RetroPie-Metroid-Construction/master/"
readonly PLUGIN_SCRIPT_NAME="metroid-construction-scriptmodule.sh"
readonly PLUGIN_SCRIPT_DESTINATION_NAME="metroid-construction.sh"
readonly RP_SETUP_DIR="$home/RetroPie-Setup"
readonly JS_SCRIPTMODULE_FOLDER="$RP_SETUP_DIR/scriptmodules/supplementary/"
readonly JS_SCRIPTMODULE_FULL="$JS_SCRIPTMODULE_FOLDER/$PLUGIN_SCRIPT_DESTINATION_NAME"
#readonly JS_SCRIPTMODULE_URL="${REPO_PATH}${PLUGIN_SCRIPT_NAME}"
readonly JS_SCRIPTMODULE="$(basename "${JS_SCRIPTMODULE_FULL%.*}")"

if [[ ! -d "$RP_SETUP_DIR" ]]; then
    echo "ERROR: \"$RP_SETUP_DIR\" directory not found!" >&2
    echo "Looks like you don't have RetroPie-Setup scripts installed in the usual place. Aborting..." >&2
    exit 1
fi

if [[ ! -s "$LOCAL_PATH/$PLUGIN_SCRIPT_NAME" ]]; then
    echo "Failed to install. Could not find source file: $LOCAL_PATH/$PLUGIN_SCRIPT_NAME Aborting..." >&2
    exit 1
fi

cp "$LOCAL_PATH/$PLUGIN_SCRIPT_NAME" "$JS_SCRIPTMODULE_FOLDER"
if [[ ! -s "$JS_SCRIPTMODULE_FOLDER/$PLUGIN_SCRIPT_NAME" ]]; then
    echo "Failed to install. Could not copy file to $JS_SCRIPTMODULE_FOLDER/$PLUGIN_SCRIPT_NAME. Aborting..." >&2
    exit 1
fi

rm -f "$JS_SCRIPTMODULE_FULL"
mv "$JS_SCRIPTMODULE_FOLDER/$PLUGIN_SCRIPT_NAME" "$JS_SCRIPTMODULE_FULL"

if [[ ! -s "$JS_SCRIPTMODULE_FULL" ]]; then
    echo "Failed to install. Could not move file. Aborting..." >&2
    exit 1
fi

## patch out the git clone with a copy command
sed -i "s|gitPullOrClone|rm -rf \"\$md_build/*\" \&\& cp \"$LOCAL_PATH/\"* \"\$md_build/\" # gitPullOrClone|g" "$JS_SCRIPTMODULE_FULL"
echo "$JS_SCRIPTMODULE_FULL"

# Install package
sudo "$RP_SETUP_DIR/retropie_packages.sh" "$JS_SCRIPTMODULE"
bash "/opt/retropie/supplementary/$JS_SCRIPTMODULE/$PLUGIN_SCRIPT_DESTINATION_NAME"
#bash "/opt/retropie/supplementary/$JS_SCRIPTMODULE/download_patch.sh" "SM" "369"