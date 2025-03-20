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
  if [ ! -d "$HOME/.config/lxsession" ];then
  mkdir -p "$HOME/.config/lxsession"
  fi

  echo 10
  if [ ! -d "$HOME/.config/lxsession/LXDE" ];then
  mkdir -p "$HOME/.config/lxsession/LXDE"
  fi

  echo 20
  if [ ! -d "$HOME/.config/gtk-3.0/" ];then
  mkdir -p "$HOME/.config/gtk-3.0/"
  fi

#  echo 30
#  xfconf-query -c xsettings -p /Net/ThemeName -s ZorinBlue-Dark
#  dbus-launch xfconf-query -c xsettings -p /Net/ThemeName -s ZorinBlue-Dark

  # echo 40
  # xfconf-query -c xsettings -p /Net/IconThemeName -s Uos-fulldistro-icons
  # dbus-launch xfconf-query -c xsettings -p /Net/IconThemeName -s Uos-fulldistro-icons

  # echo 50
  # xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg
  # dbus-launch xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg

  # echo 60
  # wget --tries=20 "https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main/config/environment/xfce4/xfce4-panel.tar.bz2"  -O ~/xfce4-panel.tar.bz2 # > /dev/null 2>&1
  # chmod +x ~/xfce4-panel.tar.bz2

  # echo 70
  # xfce4-panel-profiles load xfce4-panel.tar.bz2
  # dbus-launch xfce4-panel-profiles load xfce4-panel.tar.bz2

  echo 90
  firefox &
  PID=$(pidof firefox)
  sleep 5
  kill $PID
  sed -i '/security.sandbox.content.level/d' ~/.mozilla/firefox/*.default-release/prefs.js
  echo 'user_pref("security.sandbox.content.level", 0);' >> ~/.mozilla/firefox/*.default-release/prefs.js

  echo 100  # Finaliza em 100%
  sudo apt-get clean
  vncserver -kill :1
  rm -rf /tmp/.X$pt-lock
  rm -rf /tmp/.X11-unix/X$pt

#mkdir $HOME/.config/xfce4/
#mkdir $HOME/.config/xfce4/xconf
#mkdir $HOME/.config/xfce4/xconf/xfce-perchannel-xml
#sed -i 's|property name="last-image" type="string" value="/usr/share/backgrounds/xfce/xfce-verticals.png"property name="last-image" type="string" value="/usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg"|' $HOME/.config/xfce4/xconf/xfce-perchannel-xml/xfce4-desktop.xml

# Aqui finaliza a configuração do tema
) | whiptail --gauge "${label_config_environment_gui}" 0 0 0


dbus-launch xfconf-query -c xsettings -p /Net/ThemeName -s ZorinBlue-Dark
dbus-launch xfce4-panel-profiles load xfce4-panel.tar.bz2
dbus-launch xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg

rm -rf ~/start-environment.sh