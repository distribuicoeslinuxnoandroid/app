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

    echo 25
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg'

    echo 50
    gnome-extensions enable ubuntu-dock@ubuntu.com

    echo 100
    stopvnc

) | whiptail --gauge "${label_config_environment_gui}" 0 0 0

rm -rf ~/start-environment.sh
rm -rf /tmp/.X$pt-lock
rm -rf /tmp/.X11-unix/X$pt