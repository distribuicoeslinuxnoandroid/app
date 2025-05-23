#!/bin/bash
source "/usr/local/bin/fixed_variables.sh"
# GNOME Config

(
	echo 0  # Inicia em 0%
	echo "Oi"
	
	echo 5
	sudo apt-get install gdm3 --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 6
	sudo apt-get install policykit-1 --no-install-recommends -y > /dev/null 2>&1

	echo 10
	sudo apt-get install gnome-session --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 10
	sudo apt-get install gnome-shell --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 16 
	sudo apt-get install gnome-terminal --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 20
	sudo apt-get install dconf-cli --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 28
	sudo apt-get install dconf-cli --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 32
	sudo apt-get install gnome-tweaks --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 40
	sudo apt-get install gnome-control-center --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 48
	sudo apt-get install gnome-shell-extensions --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 50
	#sudo apt-get install gnome-shell-extension-ubuntu-dock --no-install-recommends -y > /dev/null 2>&1
	sudo apt-get install gnome-shell-extension-dashtodock --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 52
	sudo apt-get install gnome-package-updater --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 53
	sudo apt-get install gnome-calculator --no-install-recommends -y > /dev/null 2>&1
	clear

	echo 54
	sudo apt-get install lsb-release --no-install-recommends -y > /dev/null 2>&1
	clear
	
	echo 72
	# Pasta resposável pela execução do vnc
	mkdir -p ~/.vnc
	echo '#!/bin/bash
export LANG
export PULSE_SERVER=127.0.0.1
gnome-shell --x11' > ~/.vnc/xstartup
	chmod +x ~/.vnc/xstartup

	echo 88
	echo "export DISPLAY=":1"" >> /etc/profile
	source /etc/profile

	echo 94
	wget --tries=20 "${extralink}/config/environment/gnome/start-environment.sh" > /dev/null 2>&1
	chmod +x ~/start-environment.sh

	echo 100  # Finaliza em 100%
	sudo apt-get clean > /dev/null 2>&1
	sudo dpkg --configure -a > /dev/null 2>&1
	sudo apt --fix-broken install -y > /dev/null 2>&1

) | dialog --gauge "${label_install_environment_gui}" 6 40 0


vncpasswd