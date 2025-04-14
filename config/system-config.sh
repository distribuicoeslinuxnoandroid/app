#!/bin/bash
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

## Variáveis de idioma. Que irão se adequar ao idioma escolhido
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



(
  echo 0  # Inicia em 0%

	echo 10
  sudo apt autoremove --purge snapd -y > /dev/null 2>&1
  sudo apt purge snapd -y > /dev/null 2>&1
  sudo rm -rf /var/cache/snapd
  sudo rm -rf ~/snap

  echo 16 
  sudo apt purge flatpak -y > /dev/null 2>&1
  sudo apt autoremove --purge flatpak -y > /dev/null 2>&1
  sudo rm -rf /var/cache/flatpak

  echo 64  # Finaliza em 64%
  sudo apt-get clean
 ) | dialog --gauge "${label_progress}" 6 40 0


(
    echo 72  # Inicia em 0%

    echo "Aguarde, atualizando pacotes..."
    sudo apt-get update > /dev/null 2>&1
    echo 80  # Atualiza para 25% após a atualização
    sudo apt-get clean
) | dialog --gauge "${label_find_update}" 6 40 0

(
    echo 81  # Inicia em 26%
    echo "Aguarde, atualizando pacotes..."
    sudo apt-get full-upgrade -y > /dev/null 2>&1
    echo 100  # Atualiza para 100% após a atualização
    sudo apt-get clean
) | dialog --gauge "${label_update}" 6 40 0


(

	echo 0
  sudo apt-get apt-utils -y > /dev/null 2>&1

  echo 1
  sudo apt-get install exo-utils --no-install-recommends -y > /dev/null 2>&1

  echo 2 
  sudo apt-get install tigervnc-standalone-server --no-install-recommends -y > /dev/null 2>&1
    
	echo 4
  sudo apt-get install tigervnc-common --no-install-recommends -y > /dev/null 2>&1
  
  echo 6
  sudo apt-get install tigervnc-tools --no-install-recommends -y > /dev/null 2>&1
  
  echo 8
  sudo apt-get install dbus-x11 --no-install-recommends -y > /dev/null 2>&1

  echo 14
  sudo apt-get install nano -y > /dev/null 2>&1

  echo 16
  sudo apt-get install inetutils-tools -y > /dev/null 2>&1

  echo 18
  sudo apt-get install dialog -y > /dev/null 2>&1

  echo 20
  #sudo apt-get install software-properties-common -y > /dev/null 2>&1

  echo 22
  sudo apt-get install nautilus --no-install-recommends -y > /dev/null 2>&1

  echo 24
  sudo apt-get install gpg -y > /dev/null 2>&1

  echo 26
  sudo apt-get install curl -y > /dev/null 2>&1

  echo 28
  sudo apt-get install keyboard-configuration -y > /dev/null 2>&1

  echo 30
  sudo apt-get install tzdata -y > /dev/null 2>&1

  echo 32
  sudo apt-get install git -y > /dev/null 2>&1

  echo 34
  sudo apt-get install unrar -y > /dev/null 2>&1
  #sudo apt-get install gdebi --no-install-recommends -y > /dev/null 2>&1

  echo 35
  sudo apt-get install zip -y > /dev/null 2>&1

  echo 36
  sudo apt-get install font-manager --no-install-recommends -y > /dev/null 2>&1

  echo 38
  sudo apt-get install evince -y > /dev/null 2>&1

  echo 39
  sudo apt-get install synaptic --no-install-recommends -y > /dev/null 2>&1
  sudo sed -i 's/^Exec=synaptic-pkexec/Exec=synaptic/' /usr/share/applications/synaptic.desktop
  echo '[Settings]
gtk-theme-name=ZorinBlue-Dark' | sudo tee $HOME/.config/gtk-3.0/settings.ini
  echo 'gtk-theme-name="ZorinBlue-Dark"' | sudo tee $HOME/.gtkrc-2.0


  echo 40
  sudo apt-get install gvfs-backends --no-install-recommends -y > /dev/null 2>&1

  echo 42
  sudo dpkg --configure -a  

  echo 44
  if [ ! -d "/root/Desktop" ];then
    mkdir -p "/root/Desktop"
    echo "pasta criada"
  fi

  echo 45
  if [ ! -d "/usr/share/backgrounds/" ];then
    mkdir -p "/usr/share/backgrounds/"
    echo "pasta criada"
  fi

  echo 46
  if [ ! -d "/usr/share/icons/" ];then
    mkdir -p "/usr/share/icons/"
    echo "pasta criada"
  fi

  echo 47
  if [ ! -d "/root/.config/gtk-3.0" ];then
    mkdir -p ~/.config/gtk-3.0/
    echo "pasta criada"
  fi

  echo 48
  echo 'file:/// raiz
file:///sdcard sdcard' | sudo tee $HOME/.config/gtk-3.0/bookmarks


  echo 50
  sudo apt-get install at-spi2-core -y

  echo 52
  # Respositório do Firefox
  sudo install -d -m 0755 /etc/apt/keyrings
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null 2>&1

  echo 54
  # Adiciona repositório APT da Mozilla à sua lista de origens
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null 2>&1

  echo 55
  # Dar prioridade a pacotes do repositório da Mozilla:
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

  echo 60
  # APT do VSCode
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg > /dev/null 2>&1
  sudo sh -c 'echo "deb [arch=arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg

  echo 61
  sudo apt-get update > /dev/null 2>&1
  clear

  echo 65
  # APT do brave browser
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  
  echo 68
  sudo apt-get install firefox -y > /dev/null 2>&1

  echo 72
  apt_system_icu_locale_code=$(echo $LANG | sed 's/\..*//' | sed 's/_/-/' | tr '[:upper:]' '[:lower:]')
  sudo apt-get install firefox-l10n-$apt_system_icu_locale_code -y > /dev/null 2>&1

  echo 74
  sudo apt-get install code -y > /dev/null 2>&1
  sed -i 's|Exec=/usr/share/code/code|Exec=/usr/share/code/code --no-sandbox|' /usr/share/applications/code*.desktop

  echo 78
  git clone https://github.com/ZorinOS/zorin-icon-themes.git > /dev/null 2>&1

  echo 80
  git clone https://github.com/ZorinOS/zorin-desktop-themes.git > /dev/null 2>&1

  echo 82
  cd zorin-icon-themes/
  mv Zorin*/ /usr/share/icons/ > /dev/null 2>&1
  cd $HOME

  echo 84
  cd zorin-desktop-themes/
  mv Zorin*/ /usr/share/themes/
  cd $HOME
  rm -rf zorin-*-themes/

  echo 90
  sudo apt-get install bleachbit -y > /dev/null 2>&1

  sudo apt-get clean -y > /dev/null 2>&1
  sudo dpkg --configure -a > /dev/null 2>&1
  sudo apt --fix-broken install -y > /dev/null 2>&1
  clear

  echo 100  # Finaliza em 100%

  sudo apt-get clean
 ) | dialog --gauge "${label_install_script_download}" 6 40 0