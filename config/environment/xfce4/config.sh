#!/bin/bash
#XFCE4 config environment
echo -e  "\033[0;32mXFCE UI\033[0m"

extralink="https://raw.githubusercontent.com/andistro/app/main"
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

system_icu_locale_code=$(echo $LANG | sed 's/\..*//')


#Get the necessary components
(
    echo 0  # Inicia em 0%
    sudo apt-get update

    echo 8
    sudo apt-get install xfce4 --no-install-recommends -y > /dev/null 2>&1

    echo 16
    sudo apt-get install xfce4-goodies --no-install-recommends -y > /dev/null 2>&1

    echo 24
    sudo apt-get install xfce4-terminal --no-install-recommends -y > /dev/null 2>&1

    echo 32  # Finaliza em 100%
    sudo apt-get install xfce4-panel-profiles -y > /dev/null 2>&1

    echo 40  # Finaliza em 100%
    sudo apt-get install dbus-x11 --no-install-recommends -y > /dev/null 2>&1

    echo 48  # Finaliza em 100%
    sudo apt-get clean

    mkdir -p ~/.vnc

echo '#!/bin/bash
export PULSE_SERVER=127.0.0.1
export LANG
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
echo $$ > /tmp/xsession.pid
dbus-launch --exit-with-session /usr/bin/startxfce4' > ~/.vnc/xstartup

    chmod +x ~/.vnc/xstartup

    echo 'export DISPLAY=":1"' >> /etc/profile

    source /etc/profile

    wget --tries=20 "${extralink}/config/environment/xfce4/start-environment.sh" > /dev/null 2>&1
	chmod +x ~/start-environment.sh

 ) | dialog --gauge "${label_install_environment_gui}" 6 40 0

vncpasswd

