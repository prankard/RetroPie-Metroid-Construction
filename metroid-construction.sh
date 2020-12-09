#!/bin/bash

# Show Test dialog
options=("1" "Yes" "2" "No")
cmd=(dialog --title " Did this work " --menu "Is this menu showing up on your screen?" 19 80 12)
choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
echo $choice
sleep 5