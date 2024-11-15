# utils
Some utils script
- Random BackGround under gnome
```bash
gsettings set org.gnome.desktop.background picture-uri "file://$(find '/home/username/Path/to/Folder/' -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.tiff" \) | shuf -n 1)"

```
