### TODO

- [x] Add support for RAR/7Zip

- [ ] Make Retropie Extension
- [x] Add support for different games (snes-sm,nes-m1,gb-m2,gba-mf,gba-mzm)
- [ ] Make location for original unheadered roms
- [ ] Format date correctly in retropie format YYYYMMDDT000000
- [x] Add support for multiple downloads
- [ ] Add show description button in game hack page before download
- [ ] Add advanced option to reload cache

### File Structure

show_menu.sh - shows the files ready to download
	first calls create_menu_cache.sh
	this calls download_patch.sh

create_menu_cache.sh - clears and downloads menu file from wget
	parse_html_menu.py - calls this to parse the menu file

download_patch.sh - downloads a file for a patch, based on hack_id
	parse_html_game.py - gets information from the game page
	update_gamelist.py - adds the game to the gamelist file

### Temporary Files Location

cache_2020-10-10/sm_menu_data.txt
cache_2020-10-10/sm_menu_data_detailed.txt
cache_2020-10-10/menu_source.html
tmp/game.html
tmp/game_data.txt
tmp/hack.zip
tmp/patch.ips

### Installed Rom files Locations
roms/snes/metcon_112_filename.smc
roms/snes/metcon_112_filename.ips