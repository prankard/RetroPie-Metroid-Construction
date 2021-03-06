#!/usr/bin/env bash
##############
# ATTENTION! #
##############
# This file has changed (26-March-2017). Now it works as RetroPie scriptmodule.
# Name this file as ~/RetroPie-Setup/scriptmodules/suplementary/joystick-selection.sh
# and then execute the retropie_setup.sh script.
# To install the joystick-selection tool, go to
# Manage packages >> Manage experimental packages >> joystick-selection >> Install from source

readonly PLUGIN_NAME="metroid-construction"

rp_module_id="metroid-construction" # can't acces this? huh
rp_module_desc="Metroid Construction for Metroid/Metroid II/Super Metroid/Metroid Fusion/Metroid Zero Mission Hack Homebrew Content"
rp_module_help="Follow the instructions on the dialogs to configure random super metroid rom in your library"
rp_module_section="exp"

function depends_metroid-construction() {    
    getDepends "python3-bs4" "python3-lxml" "p7zip-full" "unrar-free" # pyhton html/xml parser, 7zip archive, rar archive 
    getDepends "libsdl2-dev" # Used for the joystick input I think
}

function sources_metroid-construction() {
    echo "Plugin Name: $PLUGIN_NAME"

    gitPullOrClone "$md_build" "https://github.com/prankard/RetroPie-Metroid-Construction.git"

    # Add execute permission
    chmod +x "$md_build/create_cache.sh"
    chmod +x "$md_build/download_patch.sh"
    chmod +x "$md_build/find_source_rom.sh"
    chmod +x "$md_build/functions.sh"
    chmod +x "$md_build/metroid-construction.sh"
    chmod +x "$md_build/modify_gamelist.py"
    chmod +x "$md_build/parse_html_game.py"
    chmod +x "$md_build/parse_html_menu.py"
    chmod +x "$md_build/show_menu.sh"
    chmod +x "$md_build/verify_installed_files.sh"

    # Add files folder and give it access to sudo user
    mkdir "$md_build/files"
    chmod 777 "$md_build/files"
    user="$SUDO_USER"
    [[ -z "$user" ]] && user="$(id -un)"

    
    chown "$user:$user" "$md_build/files"
}

function build_metroid-construction() {
    # Nothing needed to build for this hack
    echo "No building needed for Metroid Construction"
}

function install_metroid-construction() {
    echo "Plugin Name: $PLUGIN_NAME"
    local PLUGIN_NAME="metroid-construction"
    local scriptname="metroid-construction.sh"
    local gamelistxml="$datadir/retropiemenu/gamelist.xml"
    local rpmenu_js_sh="$datadir/retropiemenu/$scriptname"

    ln -sfv "$md_inst/$scriptname" "$rpmenu_js_sh"
    # maybe the user is using a partition that doesn't support symbolic links...
    [[ -L "$rpmenu_js_sh" ]] || cp -v "$md_inst/$scriptname" "$rpmenu_js_sh"

    cp -v "$md_build/icon.png" "$datadir/retropiemenu/icons/${PLUGIN_NAME}.png"

    cp -nv "$configdir/all/emulationstation/gamelists/retropie/gamelist.xml" "$gamelistxml"
    if grep -vq "<path>./$scriptname</path>" "$gamelistxml"; then
        xmlstarlet ed -L -P -s "/gameList" -t elem -n "gameTMP" \
            -s "//gameTMP" -t elem -n path -v "./$scriptname" \
            -s "//gameTMP" -t elem -n name -v "Metroid Construction" \
            -s "//gameTMP" -t elem -n desc -v "Install Metroid Game Homebrew from Metroid Construction" \
            -s "//gameTMP" -t elem -n image -v "./icons/${PLUGIN_NAME}.png" \
            -r "//gameTMP" -v "game" \
            "$gamelistxml"

        # XXX: I don't know why the -P (preserve original formatting) isn't working,
        #      The new xml element for joystick_selection tool are all in only one line.
        #      Then let's format gamelist.xml.
        local tmpxml=$(mktemp)
        xmlstarlet fo -t "$gamelistxml" > "$tmpxml"
        cat "$tmpxml" > "$gamelistxml"
        rm -f "$tmpxml"
    fi

    # needed for proper permissions for gamelist.xml and icons/joystick_selection.png
    chown -R $user:$user "$datadir/retropiemenu"

    # Files we want to keep (retain)
    md_ret_files=(
        #'functions.sh'
        'create_cache.sh'
        'data.ini'
        'download_patch.sh'
        'find_source_rom.sh'
        'functions.sh'
        'metroid-construction.sh'
        'modify_gamelist.py'
        'parse_html_game.py'
        'parse_html_menu.py'
        'show_menu.sh'
        'verify_installed_files.sh'
        #'varia-randomizer-generate.sh'
        #'varia-parameters.ini'
        #'varia-config.ini'
        #'varia-optional-args.sh'
	    #'varia'
	    #'files'
    )
}

function remove_metroid-construction() {
    echo "Plugin Name: $PLUGIN_NAME"
    local PLUGIN_NAME="metroid-construction"
    local scriptname="${PLUGIN_NAME}.sh"
    rm -rfv "$configdir"/*/${PLUGIN_NAME}.cfg "$datadir/retropiemenu/icons/${PLUGIN_NAME}.png" "$datadir/retropiemenu/$scriptname"
    xmlstarlet ed -P -L -d "/gameList/game[contains(path,'$scriptname')]" "$datadir/retropiemenu/gamelist.xml"
}

function gui_metroid-construction() {
    bash "$md_inst/${PLUGIN_NAME}.sh"
    #bash "$md_inst/varia-randomizer.sh"
}
