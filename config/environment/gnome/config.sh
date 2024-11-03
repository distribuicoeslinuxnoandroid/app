#!/bin/bash
echo -e  "\033[0;32mGnome UI\033[0m"

extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

if [ -f "fixed_variables.sh" ]; then
	chmod +x fixed_variables.sh
	bash fixed_variables.sh
	else
		wget --tries=20 "${extralink}/config/fixed_variables.sh" > /dev/null 2>&1 &
		chmod +x fixed_variables.sh
		bash fixed_variables.sh
fi

if grep -q "LANG=pt_BR.UTF-8" ~/.bashrc; then # Se houver o LANG de idioma dentro do bashrc
	export LANGUAGE=pt_BR.UTF-8
	export LANG=pt_BR.UTF-8
	export LC_ALL=pt_BR.UTF-8
	if [ -f "l10n_pt-BR.sh" ]; then # verifica se existe o arquivo
		chmod +x l10n_pt-BR.sh
		bash l10n_pt-BR.sh
		else
			wget --tries=20 "${extralink}/config/locale/l10n_pt-BR.sh" > /dev/null 2>&1 &
			chmod +x l10n_pt-BR.sh
			bash l10n_pt-BR.sh
	fi
fi




# LANG = C.UTF-8
clear

#sudo apt-get install notification-daemon -y

#echo '[D-BUS Service]
#Name=org.freedesktop.Notifications
#Exec=/usr/lib/notification-daemon/notification-daemon' | sudo tee /usr/share/dbus-1/services/org.freedesktop.Notifications.service

(
    echo 0  # Inicia em 0%
	echo ""
    sudo apt-get install gnome-shell -y > /dev/null 2>&1

    echo 16 

    sudo apt-get install gnome-terminal -y > /dev/null 2>&1
    
	echo 32
    
    sudo apt-get install gnome-tweaks -y > /dev/null 2>&1
    echo 48
    
    sudo apt-get install gnome-shell-extensions -y > /dev/null 2>&1
    echo 64
    
    sudo apt-get install gnome-shell-extension-ubuntu-dock -y > /dev/null 2>&1

    echo 100  # Finaliza em 100%
    sudo apt-get clean
 ) | whiptail --gauge "${label_config_environment_gui}" 0 0 0


# Pasta resposável pela execução do vnc
mkdir -p ~/.vnc
echo "#!/bin/bash
export LANG
export PULSE_SERVER=127.0.0.1
gnome-shell --x11" > ~/.vnc/xstartup

chmod +x ~/.vnc/xstartup

echo "export DISPLAY=":1"" >> /etc/profile
source /etc/profile

vncpasswd


# Configuração do tema
vncserver

gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/john-towner-JgOeRuGD_Y4.jpg'
gnome-extensions enable ubuntu-dock@ubuntu.com

vncserver -kill
rm -rf /tmp/.X$pt-lock
rm -rf /tmp/.X11-unix/X$pt