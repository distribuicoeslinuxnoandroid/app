#!/bin/bash
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
 ) | whiptail --gauge "${label_progress}" 0 0 0


(
    echo 72  # Inicia em 0%

    echo "Aguarde, atualizando pacotes..."
    sudo apt-get update > /dev/null 2>&1
    echo 80  # Atualiza para 25% após a atualização
    sudo apt-get clean
) | whiptail --gauge "${label_find_update}" 0 0 0

(
    echo 81  # Inicia em 26%
    echo "Aguarde, atualizando pacotes..."
    sudo apt-get full-upgrade -y > /dev/null 2>&1
    echo 100  # Atualiza para 100% após a atualização
    sudo apt-get clean
) | whiptail --gauge "${label_update}" 0 0 0


(

	echo 0
  sudo apt-get install exo-utils --no-install-recommends -y > /dev/null 2>&1

  echo 2 
  sudo apt-get install tigervnc-standalone-server --no-install-recommends -y > /dev/null 2>&1
    
	echo 4
  sudo apt-get install tigervnc-common --no-install-recommends -y > /dev/null 2>&1
  
  echo 6
  sudo apt-get install tigervnc-tools --no-install-recommends -y > /dev/null 2>&1
  
  echo 8
  sudo apt-get install dbus-x11 --no-install-recommends -y > /dev/null 2>&1

  echo 10
  sudo apt-get install sudo -y > /dev/null 2>&1

  echo 12
  sudo apt-get install wget -y > /dev/null 2>&1

  echo 14
  sudo apt-get install nano -y > /dev/null 2>&1

  echo 16
  sudo apt-get install inetutils-tools -y > /dev/null 2>&1

  echo 18
  sudo apt-get install dialog -y > /dev/null 2>&1

  echo 20
  sudo apt-get install software-properties-common -y > /dev/null 2>&1

  echo 22
  #sudo apt-get install nautilus --no-install-recommends -y > /dev/null 2>&1

  echo 24
  sudo apt-get install gpg -y > /dev/null 2>&1

  echo 26
  sudo apt-get install curl -y > /dev/null 2>&1

  echo 28
  sudo apt-get install keyboard-configuration -y > /dev/null 2>&1

  echo 30
  sudo apt-get install tzdata -y > /dev/null 2>&1

  echo 32
  sudo apt-get install git --no-install-recommends -y > /dev/null 2>&1

  echo 34
  #sudo apt-get install gdebi --no-install-recommends -y > /dev/null 2>&1

  echo 36
  sudo apt-get install font-manager -y > /dev/null 2>&1

  echo 38
  sudo apt-get install evince -y > /dev/null 2>&1

  echo 39
  sudo apt-get install synaptic -y > /dev/null 2>&1

  echo 40
  sudo dpkg --configure -a  

  echo 42
  # Se não existir, será criado
  if [ ! -d "/usr/share/backgrounds/" ];then
    mkdir -p "/usr/share/backgrounds/"
  fi

  echo 44

  if [ ! -d "/usr/share/icons/" ];then
    mkdir -p "/usr/share/icons/"
  fi

  echo 46

  if [ ! -d "~/.config/gtk-3.0" ];then
    mkdir -p ~/.config/gtk-3.0/
  fi

  echo 48

  echo 'file:///
  file:///sdcard' | sudo tee $HOME/.config/gtk-3.0/bookmarks

  echo 50
  ## PPA do InkScape
  sudo add-apt-repository ppa:inkscape.dev/stable -y > /dev/null 2>&1

  echo 52
  ## PPA do Firefox
  #sudo add-apt-repository ppa:mozillateam/ppa -y > /dev/null 2>&1
  

  echo 53
  # Esse comando dá a prioridade de uso para a PPA ao invés do instalador snapd e faz com que seja possível baixar o Firefox mais recente
  #echo 'Package: *
  #Pin: release o=LP-PPA-mozillateam
  #Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/mozilla-firefox

  #echo 'Package: firefox*
  #Pin: release o=Ubuntu
  #Pin-Priority: -1' | sudo tee -a /etc/apt/preferences.d/mozillateam-firefox
  
  echo 54
  ## Dá a possibilidade do Firefox atualizar quando houver uma atualização
  #echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

  echo 56
  ## PPA do LibreOffice
  sudo add-apt-repository ppa:libreoffice/ppa -y > /dev/null 2>&1

  echo 60
  ## PPA do Tema do ZorinOS
  sudo add-apt-repository ppa:zorinos/stable -y > /dev/null 2>&1


  echo 63
  # PPA do Chromium
  #sudo add-apt-repository ppa:chromium-team/beta -y

  echo 64
  ##Esse comando dá a prioridade de uso para a PPA ao invés do instalador snapd
  #echo 'Package: *
  #Pin: release o=LP-PPA-chromium-team-beta
  #Pin-Priority: 1001

  ##Package: chromium*
  #Pin: origin "LP-PPA-chromium-team-beta"
  #Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/chromium

  echo 66
  ## O PPA não tem o suporte ao Chromium para Jammy, por isso será trocado pela versão bionic
  #rm -rf /etc/apt/sources.list.d/chromium-team-ubuntu-beta-jammy.list

  echo 68
  ## Substituição pela lista do Bionix
  #echo 'deb https://ppa.launchpadcontent.net/chromium-team/beta/ubuntu/ bionic main
  # deb-src https://ppa.launchpadcontent.net/chromium-team/beta/ubuntu/ bionic  main' | sudo tee /etc/apt/sources.list.d/chromium-team-ubuntu-beta-bionic.list
  # E78o: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.PackageKit was not provided by any .service files
  #E: The repository 'https://ppa.launchpadcontent.net/chromium-team/beta/ubuntu jammy Release' does not have a Release file.


  echo 70
  # PPA do VSCode
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg > /dev/null 2>&1
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg

  echo 72
  # PPA do Brave Browser
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

  echo 74
  sudo apt-get clean
  sudo apt-get update > /dev/null 2>&1
  sudo dpkg --configure -a 
  
  echo 76
  sudo apt-get install firefox -y > /dev/null 2>&1

  echo 78
  sudo apt-get install code -y > /dev/null 2>&1
  sed -i 's|Exec=/usr/share/code/code|Exec=/usr/share/code/code --no-sandbox|' /usr/share/applications/code*.desktop

  echo 80
  git clone https://github.com/ZorinOS/zorin-icon-themes.git > /dev/null 2>&1

  echo 82
  git clone https://github.com/ZorinOS/zorin-desktop-themes.git > /dev/null 2>&1

  echo 84
  cd zorin-icon-themes/
  mv Zorin*/ /usr/share/icons/ > /dev/null 2>&1
  cd $HOME

  echo 90
  cd zorin-desktop-themes/
  mv Zorin*/ /usr/share/themes/
  cd $HOME
  rm -rf zorin-*-themes/

  echo 100  # Finaliza em 100%

  sudo apt-get clean
 ) | whiptail --gauge "${label_install_script_download}" 0 0 0



#sudo apt-get install xloadimage -y

#if [ ! -d "${HOME}/Documents" ];then
#  mkdir -p "${HOME}/Documents"
#fi

#sed -i 's|Exec=chromium-browser|Exec=chromium-browser --no-sandbox|' /usr/share/applications/chromium-browser.desktop

