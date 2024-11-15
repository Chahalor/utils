# !/bin/sh

PATH_TO_BG='/home/nduvoid/Pictures/Wallpapers'
BG=find $PATH_TO_BG -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.tiff" \) | shuf -n 1

if dpkg -l | grep gnome > /dev/null; then	# so gnome install
	gsettings set org.gnome.desktop.background picture-uri $BG
else
	echo "gnome-shell is not installed"
fi