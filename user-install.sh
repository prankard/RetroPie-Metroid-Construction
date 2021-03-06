#!/bin/bash
# installing RetroPie-MetroidConstruction

user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"
home="$(eval echo ~$user)"
readonly REPO_PATH="https://raw.githubusercontent.com/prankard/RetroPie-Metroid-Construction/master/"
readonly PLUGIN_SCRIPT_NAME="metroid-construction-scriptmodule.sh"
readonly PLUGIN_SCRIPT_DESTINATION_NAME="metroid-construction.sh"
readonly RP_SETUP_DIR="$home/RetroPie-Setup"
readonly JS_SCRIPTMODULE_FULL="$RP_SETUP_DIR/scriptmodules/supplementary/$PLUGIN_SCRIPT_DESTINATION_NAME"
readonly JS_SCRIPTMODULE_URL="${REPO_PATH}${PLUGIN_SCRIPT_NAME}"
readonly JS_SCRIPTMODULE="$(basename "${JS_SCRIPTMODULE_FULL%.*}")"

if [[ ! -d "$RP_SETUP_DIR" ]]; then
    echo "ERROR: \"$RP_SETUP_DIR\" directory not found!" >&2
    echo "Looks like you don't have RetroPie-Setup scripts installed in the usual place. Aborting..." >&2
    exit 1
fi

curl "$JS_SCRIPTMODULE_URL" -o "$JS_SCRIPTMODULE_FULL"

if [[ ! -s "$JS_SCRIPTMODULE_FULL" ]]; then
    echo "Failed to install. Aborting..." >&2
    exit 1
fi

sudo "$RP_SETUP_DIR/retropie_packages.sh" "$JS_SCRIPTMODULE"
#bash "/opt/retropie/supplementary/$JS_SCRIPTMODULE/$PLUGIN_SCRIPT_DESTINATION_NAME"