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

source /etc/profile

(
# Aqui inicia a configuração do tema
  echo 1
  vncserver -name remote-desktop -geometry 1920x1080 :1
  if [ ! -d "$HOME/.config/lxsession" ];then
    mkdir -p "$HOME/.config/lxsession"
  fi
  
  if [ ! -d "$HOME/.config/lxsession/LXDE" ];then
    mkdir -p "$HOME/.config/lxsession/LXDE"
  fi
  
  if [ ! -d "$HOME/.config/gtk-3.0/" ];then
    mkdir -p "$HOME/.config/gtk-3.0/"
  fi
    
	echo 12
  echo '[Command]
Logout=stopvnc' | sudo tee $HOME/.config/lxpanel/LXDE/config

  echo 24
echo '# lxpanel <profile> config file. Manually editing is not recommended.
# Use preference dialog in lxpanel to adjust config when you can.

Global {
  edge=bottom
  align=left
  margin=0
  widthtype=percent
  width=100
  height=54
  transparent=0
  tintcolor=#000000
  alpha=0
  setdocktype=1
  setpartialstrut=1
  autohide=0
  heightwhenhidden=0
  usefontcolor=1
  fontcolor=#ffffff
  background=0
  backgroundfile=/usr/share/lxpanel/images/background.png
  iconsize=48
  usefontsize=1
  fontsize=12
}
Plugin {
  type=space
  Config {
    Size=20
  }
}
Plugin {
  type=menu
  Config {
    system {
    }
    separator {
    }
    item {
      command=run
    }
    separator {
    }
    item {
      command=logout
      image=gnome-logout
    }
    image=/usr/share/lxpanel/images/my-computer.png
  }
}
Plugin {
  type=space
  Config {
    Size=20
  }
}
Plugin {
  type=launchbar
  Config {
    Button {
      id=firefox.desktop
    }
  }
}
Plugin {
  type=space
  Config {
    Size=20
  }
}
Plugin {
  type=taskbar
  Config {
    IconsOnly=0
    FlatButton=-1
    ShowAllDesks=-1
    UseMouseWheel=-1
    GroupedTasks=0
    DisableUpscale=0
    SameMonitorOnly=0
  }
}
Plugin {
  type=space
  Config {
  }
  expand=1
}
Plugin {
  type=dclock
  Config {
    ClockFmt=%D %R
    TooltipFmt=%A %x
    BoldFont=0
    IconOnly=0
    CenterText=0
  }
}
Plugin {
  type=space
  Config {
    Size=20
  }
}' | sudo tee $HOME/.config/lxpanel/LXDE/panels/panel

echo 36
echo '@lxpanel --profile LXDE
@pcmanfm --desktop --profile LXDE
@xscreensaver -no-splash' | sudo tee $HOME/.config/lxsession/LXDE/autostart

echo 48
echo '[Session]
window_manager=openbox-lxde
disable_autostart=no
polkit/command=
clipboard/command=lxclipboard
xsettings_manager/command=build-in
proxy_manager/command=build-in
keyring/command=ssh-agent
quit_manager/command=stopvnc
lock_manager/command=stopvnc
terminal_manager/command=lxterminal
quit_manager/image=/usr/share/lxde/images/logout-banner.png
quit_manager/layout=top

[GTK]
sNet/ThemeName=ZorinBlue-Dark
sNet/IconThemeName=Zorin
sGtk/FontName=Sans 10
iGtk/ToolbarStyle=3
iGtk/ButtonImages=1
iGtk/MenuImages=1
iGtk/CursorThemeSize=18
iXft/Antialias=1
iXft/Hinting=1
sXft/HintStyle=hintslight
sXft/RGBA=rgb
iNet/EnableEventSounds=1
iNet/EnableInputFeedbackSounds=1
sGtk/ColorScheme=
iGtk/ToolbarIconSize=3
sGtk/CursorThemeName=DMZ-White

[Mouse]
AccFactor=20
AccThreshold=10
LeftHanded=0

[Keyboard]
Delay=500
Interval=30
Beep=1

[State]
guess_default=true

[Dbus]
lxde=true

[Environment]
menu_prefix=lxde-' | sudo tee $HOME/.config/lxsession/LXDE/desktop.conf


echo 60
echo '[Settings]
gtk-theme-name=ZorinBlue-Dark
gtk-icon-theme-name=Zorin
gtk-font-name=Sans 10
gtk-cursor-theme-size=18
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb' | sudo tee $HOME/.config/gtk-3.0/settings.ini


  echo 72
  #echo 'file:///sdcard' | sudo tee $HOME/.config/gtk-3.0/bookmarks
  sed -i 's|wallpaper=/etc/alternatives/desktop-background|wallpaper=/usr/share/backgrounds/wai-hsuen-chan-DnmMLipPktY.jpg|' ~/.config/pcmanfm/LXDE/desktop-items-0.conf

  echo 90
  firefox > /dev/null 2>&1 &
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

  # Aqui finaliza a configuração do tema
 ) | dialog --gauge "${label_config_environment_gui}" 6 40 0

 rm -rf ~/start-environment.sh