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

    echo "export DISPLAY=":1"" >> /etc/profile > /dev/null 2>&1

    source /etc/profile

 ) | whiptail --gauge "${label_config_environment_gui}" 0 0 0


#Get the necessary components


vncpasswd

vncserver -name remote-desktop -geometry 1920x1080 :1
sleep 2

(
    echo 56   # Inicia em 0%
    apt update > /dev/null 2>&1
    xfconf-query -c xsettings -p /Net/ThemeName -s ZorinBlue-Dark
    sleep 2

    echo 64   # Inicia em 0%
    xfconf-query -c xsettings -p /Net/IconThemeName -s Uos-fulldistro-icons
    sleep 2

    echo 72   # Inicia em 0%
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg
    sleep 2

    echo 80   # Inicia em 0%
    wget --tries=20 "https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main/config/environment/xfce4/xfce4-panel.tar.bz2"  -O ~/xfce4-panel.tar.bz2 > /dev/null 2>&1
    chmod +x ~/xfce4-panel.tar.bz2
    xfce4-panel-profiles load xfce4-panel.tar.bz2
    sleep 2

    echo 88   # Inicia em 0%
    mkdir $HOME/.config/gtk-3.0/

    echo 89   # Inicia em 0%
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg
    sleep 2

    echo 96   # Inicia em 0%
    echo 'file:///sdcard' | sudo tee $HOME/.config/gtk-3.0/bookmarks

    echo 100  # Finaliza em 100%
    sudo apt-get clean

 ) | whiptail --gauge "${label_config_environment_gui}" 0 0 0


#mkdir $HOME/.config/xfce4/
#mkdir $HOME/.config/xfce4/xconf
#mkdir $HOME/.config/xfce4/xconf/xfce-perchannel-xml

# Certificação para caso de erro


#sed -i 's|property name="last-image" type="string" value="/usr/share/backgrounds/xfce/xfce-verticals.png"property name="last-image" type="string" value="/usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg"|' $HOME/.config/xfce4/xconf/xfce-perchannel-xml/xfce4-desktop.xml
vncserver -kill

rm -rf /root/.vnc/localhost:5901.pid
rm -rf /tmp/.X$pt-lock
rm -rf /tmp/.X11-unix/X$pt
#rm -rf xfce4-panel.tar.bz2
#rm -rf Uos-fulldistro-icons.tar.xz
