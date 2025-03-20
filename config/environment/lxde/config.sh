#!/bin/bash
echo -e  "\033[0;32mLXDE UI\033[0m"

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



#Get the necessary components
(
	echo 0  # Inicia em 0%
	echo "Oi"

	echo 8
	sudo apt-get install lxde-core --no-install-recommends -y > /dev/null 2>&1
  	#apt remove lxlock lightdm light-locker -y > /dev/null 2>&1

	echo 16
	sudo apt-get install lxterminal --no-install-recommends -y > /dev/null 2>&1
    
	echo 24
	sudo apt-get install lxappearance --no-install-recommends -y > /dev/null 2>&1

	echo 38
	sudo apt-get install exo-utils --no-install-recommends -y > /dev/null 2>&1

	echo 40
	sudo apt-get install tigervnc-standalone-server --no-install-recommends -y > /dev/null 2>&1
    
	echo 48
	sudo apt-get install tigervnc-common --no-install-recommends -y > /dev/null 2>&1
    
	echo 64
	sudo apt-get install tigervnc-tools --no-install-recommends -y > /dev/null 2>&1
    
	echo 70
	sudo apt-get install dbus-x11 --no-install-recommends -y > /dev/null 2>&1

	echo 76
	sudo apt install python3-gi -y > /dev/null 2>&1

	echo 80
	sudo apt install python3 -y > /dev/null 2>&1

	echo 100  # Finaliza em 100%
	sudo apt-get clean

	echo '#!/bin/bash
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
export PULSE_SERVER=127.0.0.1
export LANG
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
echo $$ > /tmp/xsession.pid
dbus-launch --exit-with-session startlxde' > ~/.vnc/xstartup

	chmod +x ~/.vnc/xstartup

	echo 'export DISPLAY=":1"' >> /etc/profile
	source /etc/profile

	wget --tries=20 "${extralink}/config/environment/lxde/start-environment.sh" > /dev/null 2>&1
	chmod +x ~/start-environment.sh

) | whiptail --gauge "${label_config_environment_gui}" 0 0 0


vncpasswd


#rm -rf /tmp/.X$pt-lock
#rm -rf /tmp/.X11-unix/X$pt
#rm -rf Uos-fulldistro-icons.tar.xz
#rm -rf /root/.vnc/localhost:1.log