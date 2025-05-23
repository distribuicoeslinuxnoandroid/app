#!/bin/bash
#XFCED4 start environment
source "/usr/local/bin/fixed_variables.sh"
source /etc/profile

(
# Aqui inicia a configuração do tema
  echo 1
  vncserver -name remote-desktop -geometry 1920x1080 :1
  source /etc/profile

  echo 10
  sleep 15

  echo 20
  if [ ! -d "$HOME/.config/gtk-3.0/" ];then
  mkdir -p "$HOME/.config/gtk-3.0/"
  fi

  echo 25
  xfce4-session > /dev/null 2>&1 &
  sleep 10

  echo 30
  xfconf-query -c xsettings -p /Net/ThemeName -s ZorinBlue-Dark
  dbus-launch xfconf-query -c xsettings -p /Net/ThemeName -s ZorinBlue-Dark

  echo 40
  xfconf-query -c xsettings -p /Net/IconThemeName -s ZorinBlue-Dark
  dbus-launch xfconf-query -c xsettings -p /Net/IconThemeName -s ZorinBlue-Dark

  echo 50
  xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVNC-0/workspace0/last-image --create --type string --set "/usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg"

  sleep 4
  dbus-launch xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVNC-0/workspace0/last-image --create --type string --set "/usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg"
  
  sleep 4
  sed -i 's|property name="last-image" type="string" value="/usr/share/backgrounds/xfce/xfce-verticals.png"property name="last-image" type="string" value="/usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg"|' $HOME/.config/xfce4/xconf/xfce-perchannel-xml/xfce4-desktop.xml

  echo 60
  wget --tries=20 "https://raw.githubusercontent.com/andistro/app/main/config/environment/xfce4/xfce4-panel.tar.bz2"  -O ~/xfce4-panel.tar.bz2 > /dev/null 2>&1
  chmod +x ~/xfce4-panel.tar.bz2

  echo 70
  xfce4-panel-profiles load xfce4-panel.tar.bz2
  dbus-launch --exit-with-session xfce4-panel-profiles load xfce4-panel.tar.bz2

  echo 90
  firefox > /dev/null 2>&1 &
  PID=$(pidof firefox)
  sleep 5
  kill $PID
  sed -i '/security.sandbox.content.level/d' ~/.mozilla/firefox/*.default-release/prefs.js
  echo 'user_pref("security.sandbox.content.level", 0);' >> ~/.mozilla/firefox/*.default-release/prefs.js

  echo 100  # Finaliza em 100%
  sudo apt-get clean
  
  stopvnc
  rm -rf /tmp/.X$pt-lock
  rm -rf /tmp/.X11-unix/X$pt

# Aqui finaliza a configuração do tema
) | dialog --gauge "${label_config_environment_gui}" 0 0 0

rm -rf ~/start-environment.sh
