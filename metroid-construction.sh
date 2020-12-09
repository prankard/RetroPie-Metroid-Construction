#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

bash $DIR/show_menu.sh
# Show Test dialog
#options=("1" "Yes" "2" "No")
#cmd=(dialog --title " Did this work " --menu "Is this menu showing up on your screen?" 19 80 12)
#choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
#echo $choice
#sleep 1