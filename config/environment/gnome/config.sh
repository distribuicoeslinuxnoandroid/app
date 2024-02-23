#!/bin/bash
echo -e  "\033[0;32mGnome UI\033[0m"

clear
# Instalar pacotes necessários da interface
sudo apt-get install gnome-shell gnome-terminal gnome-tweaks gnome-shell-extensions gnome-shell-extension-ubuntu-dock -y
#sudo apt-get install  yaru-theme-gtk yaru-theme-icon -y
sudo apt-get clean

# Pasta resposável pela execução do vnc
mkdir -p ~/.vnc
echo "#!/bin/bash
export PULSE_SERVER=127.0.0.1
gnome-shell --x11" > ~/.vnc/xstartup

chmod +x ~/.vnc/xstartup

echo "export DISPLAY=":1"" >> /etc/profile
source /etc/profile

vncpasswd


# Configuração do tema
vncserver -name remote-desktop -geometry 1920x1080 :1

gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/john-towner-JgOeRuGD_Y4.jpg'
vncserver -kill
rm -rf /tmp/.X$pt-lock
rm -rf /tmp/.X11-unix/X$pt