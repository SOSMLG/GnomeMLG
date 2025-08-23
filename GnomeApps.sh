#BackPorts For Trixie 
"deb http://deb.debian.org/debian/ trixie-backports main non-free-firmware"
"deb-src http://deb.debian.org/debian/ trixie-backports main non-free-firmware"
# flatpack configuration 
sudo apt update -yy
sudo apt upgrade -yy
sudo apt install flatpak -yy
sudo apt install gnome-software-plugin-flatpak -yy
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# Oh My Bash
sudo apt install git -yy
bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
# installing Other Apps 
sudo apt install vlc micro libreoffice tilix fastfetch  unrar unzip cargo p7zip ntfs-3g  ffmpeg ttf-mscorefonts-installer fonts-firacode fonts-jetbrains-mono fonts-croscore fonts-crosextra-carlito fonts-crosextra-caladea fonts-noto fonts-noto-cjk extrepo -yy
sudo apt purge nano gnome-terminal firefox-esr -yy
sudo apt autoremove
# librewolf
sudo extrepo enable librewolf 
sudo apt update && sudo apt install librewolf -y
