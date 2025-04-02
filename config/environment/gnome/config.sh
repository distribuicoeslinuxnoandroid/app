#!/bin/bash
echo -e  "\033[0;32mGnome UI\033[0m"

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
			) | dialog --gauge "${label_progress}" 6 40 0

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
			) | dialog --gauge "${label_progress}" 6 40 0
		chmod +x l10n_$system_icu_locale_code.sh
    source "l10n_${system_icu_locale_code}.sh"
fi


clear

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