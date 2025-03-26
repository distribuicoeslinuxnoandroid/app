#!/bin/bash
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"
system_icu_locale_code=$(echo $LANG | sed 's/\..*//' | sed 's/_/-/')

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
if [ -f "l10n_${system_icu_locale_code}.sh" ]; then
	source l10n_$system_icu_locale_code.sh
	else

    (
				echo 51  # Inicia
				wget --tries=20 "${extralink}/config/locale/l10n_${system_icu_locale_code}.sh" --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 100  # Finaliza
			) | whiptail --gauge "${label_progress}" 0 0 0
		chmod +x l10n_$system_icu_locale_code.sh
    source "l10n_${system_icu_locale_code}.sh"
fi

source /etc/profile

(
# Aqui inicia a configuração do tema
    echo 1
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
	gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop']" "['firefox.desktop']"

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

) | whiptail --gauge "${label_config_environment_gui}" 0 0 0

rm -rf ~/start-environment.sh
rm -rf /tmp/.X$pt-lock
rm -rf /tmp/.X11-unix/X$pt