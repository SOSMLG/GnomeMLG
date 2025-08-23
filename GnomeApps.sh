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
