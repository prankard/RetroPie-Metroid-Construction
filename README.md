# RetroPie-Metroid-Construction

## Requirements

For the plugin to work, it searches for a game called 'Super Metroid' in your snes game lists. Ensure you have the Super Metroid rom and you have successfully scrapped or added the correct meta-data to RetroPie to have the name 'Super Metroid'.

## Installation

1. If you're on EmulationStation, press `F4` to go to the Command Line Interface.

2. Download the `user-install.sh` script, and launch it:

```bash
curl https://raw.githubusercontent.com/prankard/RetroPie-Metroid-Construction/master/user-install.sh -o user-install.sh
bash user-install.sh
```

3. The script will automatically download the joystick-selection scriptmodule and install everything you need. After installation you can safely delete the `user-install.sh` file:

```bash
rm user-install.sh
```

4. **After that you are ready to use it via RetroPie menu in emulationstation:**

```bash
emulationstation
```

#### Thanks to

Of course, full credit to the [Metroid Construction](https://metroidconstruction.com/) which you can run on a web browser to download Metroid homebrew for all metroid games. All respective developers of each hack put tons of effort into making something fun to play. So please go there to leave reviews/content

Thanks to the source files of [RetroPie Joystick Selection](https://github.com/meleu/RetroPie-joystick-selection) for their decent plugin that is very useful to follow and basic blatent copying of installation technique and scriptmodule setup