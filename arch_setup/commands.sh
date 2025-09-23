############# # install vscode and other stuff

sudo pacman -Syu sway nemo nautilus waybar wofi kitty vscode

yay eww

sudo pacman -S ly

yay -S ttf-font-awesome

## after adding maple mono efresh cache
fc-cache -f -t


###  Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


## disable the power button from powering off things in systemd
# edit:
/etc/systemd/logind.conf
# to chang the power button behavior 

# add lunatask
yay -S lunatask

# add vlc
sudo pacman -Syu vlc

# If backslash / altgr stops working this run this and re-login
dconf reset -f /org/gnome/desktop/input-sources/

sudo pacman -S docker docker-compose 






#### automate these:
# output max brr324qightness
cat /sys/class/leds/*kbd_backlight*/max_brightness

# set brightnes to 2 (max in this case)
echo 2 | sudo tee /sys/class/leds/*kbd_backlight*/brightness


# Use nvm to node nodejs and npm, the pacman version acts weird