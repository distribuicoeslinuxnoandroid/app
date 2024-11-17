#!/bin/bash
echo -e  "\033[0;32mGnome UI\033[0m"

extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

if [ -f "fixed_variables.sh" ]; then
	chmod +x fixed_variables.sh
	source fixed_variables.sh
	else
		(
				echo 0  # Inicia em 0%
				wget --tries=20 "${extralink}/config/fixed_variables.sh" --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 50  # Finaliza em 50%
			) | whiptail --gauge "${label_progress}" 0 0 0

		chmod +x fixed_variables.sh
		source fixed_variables.sh
fi

if grep -q "LANG=pt_BR.UTF-8" ~/.bashrc; then # Se houver o LANG de idioma dentro do bashrc
	export LANGUAGE=pt_BR.UTF-8
	export LANG=pt_BR.UTF-8
	export LC_ALL=pt_BR.UTF-8
	if [ -f "l10n_pt-BR.sh" ]; then # verifica se existe o arquivo
		chmod +x l10n_pt-BR.sh
		source l10n_pt-BR.sh
		else
			(
				echo 51  # Inicia em 51%
				wget --tries=20 "${extralink}/config/locale/l10n_pt_BR.sh" --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 100  # Finaliza em 100%
			) | whiptail --gauge "${label_progress}" 0 0 0
			chmod +x l10n_pt-BR.sh
			source l10n_pt-BR.sh
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
	echo "Oi"

	echo 10
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
gnome-shell --x11" > ~/.vnc/xstartup > /dev/null 2>&1

chmod +x ~/.vnc/xstartup

echo "export DISPLAY=":1"" >> /etc/profile
source /etc/profile

vncpasswd


# Configuração do tema

vncserver -name remote-desktop -geometry 1920x1080 :1
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg'
gnome-extensions enable ubuntu-dock@ubuntu.com

vncserver -kill
rm -rf /tmp/.X$pt-lock
rm -rf /tmp/.X11-unix/X$pt
rm -rf ~/l10n*.sh