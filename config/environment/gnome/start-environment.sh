#!/bin/bash
#Gnome Start enviroment
source "/usr/local/bin/fixed_variables.sh"

source /etc/profile

(
# Aqui inicia a configuração do tema
    echo 1
	touch ~/.Xauthority
	#chmod 600 ~/.Xauthority
    vncserver -name remote-desktop -geometry 1920x1080 :1
	clear
	
	echo 2 
	sleep 2

    echo 20
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/john-towner-JgOeRuGD_Y4.jpg'
	gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/john-towner-JgOeRuGD_Y4.jpg'
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark

    echo 30
    #gnome-extensions enable ubuntu-dock@ubuntu.com
	gnome-extensions enable dash-to-dock@micxgx.gmail.com

	echo 40
	gsettings set org.gnome.desktop.interface icon-theme "ZorinBlue-Dark"

	echo 50
	gsettings set org.gnome.desktop.interface gtk-theme "ZorinBlue-Dark"

	echo 55
	#GTK_THEME=ZorinBlue-Dark synaptic

	echo 60
	gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop']"

	echo 70
	# Irá remover os erros de inicialização do Firefox
	firefox > /dev/null 2>&1 &
	PID=$(pidof firefox)
	sleep 5
	kill $PID
	sed -i '/security.sandbox.content.level/d' ~/.mozilla/firefox/*.default-release/prefs.js
	echo 'user_pref("security.sandbox.content.level", 0);' >> ~/.mozilla/firefox/*.default-release/prefs.js

	echo 80
	gsettings set org.gnome.desktop.session idle-delay 0

	echo 81
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0

	echo 82
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0

    echo 90
	sudo apt-get remove --purge lilyterm -y > /dev/null 2>&1
	mv /root/.config/lilyterm/default.conf /root/.config/lilyterm/default.conf.bak > /dev/null 2>&1

	echo 95
	sudo apt-get autoremove --purge zutty -y > /dev/null 2>&1

	echo 100
	sudo apt-get clean -y > /dev/null 2>&1
	sudo apt-get autoclean -y > /dev/null 2>&1
	sudo apt-get autoremove -y > /dev/null 2>&1
	sudo apt-get purge -y > /dev/null 2>&1
    stopvnc

) | dialog --gauge "${label_config_environment_gui}" 6 40 0

rm -rf ~/start-environment.sh
rm -rf /tmp/.X$pt-lock
rm -rf /tmp/.X11-unix/X$pt