#!/data/data/com.termux/files/usr/bin/bash

apt install wget -y >/dev/null 2>&1
apt install debootstrap -y >/dev/null 2>&1
apt install proot -y >/dev/null 2>&1

extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"
system_icu_locale_code=$(getprop persist.sys.locale)

# Variáveis do sistema
folder=debian-stable
codinome=debian-stable

## Variáveis fixas, que sempre irão se repetir em várias partes do instalador
if [ -f "fixed_variables.sh" ]; then
	source fixed_variables.sh
	else

  (
				echo 76  # Inicia
				wget --tries=20 "${extralink}/config/fixed_variables.sh" --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 80  # Finaliza
			) | whiptail --gauge "${label_progress}" 0 0 0

		chmod +x fixed_variables.sh
		source fixed_variables.sh
fi

## Variáveis de idioma. Que irão se adequar ao idioma escolhido
if [ -f "l10n_${system_icu_locale_code}.sh" ]; then
	source l10n_$system_icu_locale_code.sh
	else


    (
				echo 81  # Inicia
				wget --tries=20 "${extralink}/config/locale/l10n_${system_icu_locale_code}.sh" --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 90  # Finaliza
			) | whiptail --gauge "${label_progress}" 0 0 0
		chmod +x l10n_$system_icu_locale_code.sh
    source "l10n_${system_icu_locale_code}.sh"
fi

# Carregamento de inicialização do instalador
# GUI
(
  while [ "$(pidof apt)" ]; do
    sleep 0.1
    echo "90"
  done
  echo "100"
  sleep 1
) | whiptail --gauge "${label_progress}" 0 0 0
clear

if [ -d "$folder" ]; then
	first=1
	echo "${label_skip_download}"
fi

if [ "$first" != 1 ];then
		case `dpkg --print-architecture` in
		aarch64)
			archurl="arm64" ;;
		arm)
			archurl="armhf" ;;
		*)
			echo "unknown architecture"; exit 1 ;;
		esac
        	debootstrap --arch=$archurl stable debian-stable http://ftp.debian.org/debian/  >/dev/null 2>&1 &
			debootstrap_pid=$!
			
			#GUI
			(
				while kill -0 $debootstrap_pid >/dev/null 2>&1; do
					sleep $whiptail_intervalo
					((percentage+=2))

					# Limita a barra a 95% até a conclusão
					if [ $percentage -gt 95 ]; then
					percentage=95
					fi

					echo "$label_debian_download"
					echo "$percentage"
				done

				# Finaliza a barra 
				echo "$label_debian_download"
				echo "100"
				sleep 2

			) | whiptail --gauge "$label_debian_download" 0 0 0
			###
			if wait $debootstrap_pid; then
				echo "Instalação concluída com sucesso!"
			else
				echo "Erro durante a instalação do Debian!"
			fi

fi

mkdir -p debian-binds
bin=start-debian.sh

echo "${label_start_script}"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A debian-binds)" ]; then
    for f in debian-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b $folder/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "127.0.0.1 localhost localhost" > $folder/etc/hosts

# Se não existir, será criado
if [ ! -d "$folder/usr/share/backgrounds/" ];then
  mkdir -p "$folder/usr/share/backgrounds/"
fi


if [ ! -d "$folder/usr/share/icons/" ];then
  mkdir -p "$folder/usr/share/icons/"
fi
# Baixando o arquivo de configuração do sistema
(
    echo 0  # Inicia

    echo "${label_install_script_download}"
    wget --tries=20 "${extralink}/config/system-config.sh" -O "$folder/root/system-config.sh" --progress=dot:giga 2>&1 | while read -r line; do
        # Extraindo a porcentagem do progresso do wget
        if [[ $line =~ ([0-9]+)% ]]; then
            percent=${BASH_REMATCH[1]}
            echo $percent  # Atualiza a barra de progresso
        fi 
    done

    chmod +x "$folder/root/system-config.sh"
    echo 34  # Finaliza
) | whiptail --gauge "${label_progress}" 0 0 0

# Baixar dois papei de parede
(
    echo 35 # Inicia

    echo "${label_wallpaper_download}"
    wget --tries=20 "${extralink}/config/wallpapers/unsplash/john-towner-JgOeRuGD_Y4.jpg" -P "$folder/usr/share/backgrounds" --progress=dot:giga 2>&1 | while read -r line; do
        # Extraindo a porcentagem do progresso do wget
        if [[ $line =~ ([0-9]+)% ]]; then
            percent=${BASH_REMATCH[1]}
            echo $percent  # Atualiza a barra de progresso
        fi
    done

    echo 65
    echo "${label_wallpaper_download}"
    wget --tries=20 "${extralink}/config/wallpapers/unsplash/wai-hsuen-chan-DnmMLipPktY.jpg" -P "$folder/usr/share/backgrounds" --progress=dot:giga 2>&1 | while read -r line; do
        # Extraindo a porcentagem do progresso do wget
        if [[ $line =~ ([0-9]+)% ]]; then
            percent=${BASH_REMATCH[1]}
            echo $percent  # Atualiza a barra de progresso
        fi
    done

    echo 100  # Finaliza
) | whiptail --gauge "${label_progress}" 0 0 0


# Idioma
export PORT=1
#Definir o idioma
	OPTIONS=(1 "Português do Brasil (pt-BR)"
			 2 "English (en-US)")
	CHOICE=$(dialog --clear \
					--title "$TITLE" \
					--menu "$MENU_language_select" \
					$HEIGHT $WIDTH $CHOICE_HEIGHT \
					"${OPTIONS[@]}" \
					2>&1 >/dev/tty)

	clear
	case $CHOICE in
		1)

			if [ -f "l10n_pt-BR.sh" ]; then
				source l10n_pt-BR.sh
				else
					wget --tries=20 "${extralink}/config/locale/l10n_pt-BR.sh" > /dev/null 2>&1 &
					chmod +x l10n_pt-BR.sh
					source l10n_pt-BR.sh
			fi
			(
				echo 0  # Inicia 
				sed -i 's|command+=" LANG=C.UTF-8"|command+=" LANG=pt_BR.UTF-8"|' $bin
				wget --tries=20 "${extralink}/config/locale/locale_pt-BR.sh" -P $folder/root > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 14  # Finaliza
			) | whiptail --gauge "${label_language_download}" 0 0 0

			chmod +x $folder/root/locale_pt-BR.sh
		;;

		2)
		if [ -f "l10n_en-US.sh" ]; then
				source l10n_en-US.sh
				else
					wget --tries=20 "${extralink}/config/locale/l10n_en-US.sh" > /dev/null 2>&1 &
					chmod +x l10n_en-US.sh
					source l10n_en-US.sh
			fi
		;;
	esac

(
	echo 15  # Inicia
	wget --tries=20 "${extralink}/config/tigervnc/vnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
		# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done

	echo 30  # Inicia
	wget --tries=20 "${extralink}/config/tigervnc/vncpasswd" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
		# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done

	echo 45  # Inicia
	wget --tries=20 "${extralink}/config/tigervnc/startvnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
		# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done

	echo 60  # Inicia
	wget --tries=20 "${extralink}/config/tigervnc/stopvnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
		# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done

	echo 75  # Inicia 
	wget --tries=20 "${extralink}/config/tigervnc/startvncserver" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
		# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done

	echo 100  # Finaliza
) | whiptail --gauge "${label_language_download}" 0 0 0

#Copiando arquivos para dentro do linux


cp l10n_*.sh $folder/root/
chmod +x $folder/root/l10n_*.sh
cp fixed_variables.sh $folder/root/
chmod +x $folder/root/fixed_variables.sh

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin

echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
touch $folder/root/.hushlogin
echo "#!/bin/bash
rm -rf /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
mkdir -p ~/.vnc

echo '${label_alert_autoupdate_for_u}'
apt update -y > /dev/null 2>&1
apt install dialog whiptail -y > /dev/null 2>&1
apt install sudo wget -y > /dev/null 2>&1 

bash ~/locale*.sh

apt update

rm -rf ~/locale*.sh
rm -rf ~/.bash_profile
exit" > $folder/root/.bash_profile 

bash $bin

# Interface de Download do

export USER=$(whoami)
export PORT=1
OPTIONS=(1 "LXDE"
		 2 "XFCE"
		 3 "Gnome")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU_environments_select" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
1)	
		(
		echo 0  # Inicia em 0%
		echo "LXDE UI"
		wget --tries=20  "${extralink}/config/environment/lxde/config.sh" -O $folder/root/config-environment.sh > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
			# Extraindo a porcentagem do progresso do wget
			if [[ $line =~ ([0-9]+)% ]]; then
				percent=${BASH_REMATCH[1]}
				echo $percent  # Atualiza a barra de progresso
			fi
		done
		sleep 1
		echo 100  # Finaliza em 100%
	) | whiptail --gauge "${label_config_environment_gui}" 0 0 0
;;
2)	
	(
		echo 0  # Inicia em 0%
		echo "XFCE UI"
		wget --tries=20  "${extralink}/config/environment/xfce4/config.sh" -O $folder/root/config-environment.sh > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
			# Extraindo a porcentagem do progresso do wget
			if [[ $line =~ ([0-9]+)% ]]; then
				percent=${BASH_REMATCH[1]}
				echo $percent  # Atualiza a barra de progresso
			fi
		done
		sleep 1
		echo 100  # Finaliza em 100%
	) | whiptail --gauge "${label_config_environment_gui}" 0 0 0
;;
3)
	(
		echo 0  # Inicia em 0%
		echo "Gnome UI"
		wget --tries=20  "${extralink}/config/environment/gnome/config.sh" -O $folder/root/config-environment.sh > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
			# Extraindo a porcentagem do progresso do wget
			if [[ $line =~ ([0-9]+)% ]]; then
				percent=${BASH_REMATCH[1]}
				echo $percent  # Atualiza a barra de progresso
			fi
		done
		sleep 1
		echo 100  # Finaliza em 100%
	) | whiptail --gauge "${label_config_environment_gui}" 0 0 0
	# Sem isso o gnome não funciona
	apt install dbus -y > /dev/null 2>&1


	# Parte da resolução do problema do gnome e do systemd
	mkdir /data/data/com.termux/files/usr/var/run/dbus > /dev/null 2>&1 # criar a pasta que o dbus funcionará
	rm -rf /data/data/com.termux/files/usr/var/run/dbus/pid #remover o pid para que o dbus-daemon funcione corretamente
	rm -rf system_bus_socket

	dbus-daemon --fork --config-file=/data/data/com.termux/files/usr/share/dbus-1/system.conf --address=unix:path=system_bus_socket > /dev/null 2>&1 #cria o arquivo

	if grep -q "<listen>tcp:host=localhost" /data/data/com.termux/files/usr/share/dbus-1/system.conf > /dev/null && # verifica se existe a linha com esse texto
	grep -q "<listen>unix:tmpdir=/tmp</listen>" /data/data/com.termux/files/usr/share/dbus-1/system.conf > /dev/null && # verifica se existe a linha com esse texto
	grep -q "<auth>ANONYMOUS</auth>" /data/data/com.termux/files/usr/share/dbus-1/system.conf > /dev/null && # verifica se existe a linha com esse texto
	grep -q "<allow_anonymous/>" /data/data/com.termux/files/usr/share/dbus-1/system.conf > /dev/null ; then # verifica se existe a linha com esse texto
		echo ""
		else
		echo "" # caso não exista as linhas verificadas, alterar e adicionar as linhas no arquivo usando o sed
		sed -i 's|<auth>EXTERNAL</auth>|<listen>tcp:host=localhost,bind=*,port=6667,family=ipv4</listen>\
	<listen>unix:tmpdir=/tmp</listen>\
	<auth>EXTERNAL</auth>\
	<auth>ANONYMOUS</auth>\
	<allow_anonymous/>|' /data/data/com.termux/files/usr/share/dbus-1/system.conf
	fi

	# É necessário repetir o processo toda vez que alterar o system.conf
	rm -rf /data/data/com.termux/files/usr/var/run/dbus/pid
	dbus-daemon --fork --config-file=/data/data/com.termux/files/usr/share/dbus-1/system.conf --address=unix:path=system_bus_socket
	sed -i '\|command+=" -b /proc/self/fd:/dev/fd"|a command+=" -b system_bus_socket:/run/dbus/system_bus_socket"' $bin
	sed -i '1 a\rm -rf /data/data/com.termux/files/usr/var/run/dbus/pid \ndbus-daemon --fork --config-file=/data/data/com.termux/files/usr/share/dbus-1/system.conf --address=unix:path=system_bus_socket\n' $bin
;;
esac

chmod +x $folder/root/config-environment.sh

# Cria uma gui de inicialização
sed -i '\|command+=" /bin/bash --login"|a command+=" -b /data/data/com.termux/files/home/debian-stable/usr/local/bin/startvncserver"' $bin

touch $folder/root/.hushlogin

echo '#!/bin/bash
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
			) | whiptail --gauge "${label_progress}" 0 0 0
		chmod +x l10n_$system_icu_locale_code.sh
    source "l10n_${system_icu_locale_code}.sh"
fi

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"
(
    echo 0  # Inicia em 0%

    echo "Aguarde, atualizando pacotes..."
    sudo apt update > /dev/null 2>&1
    echo 25  # Atualiza para 100% após a atualização
) | whiptail --gauge "${label_find_update}" 0 0 0

(
    echo 26  # Inicia em 0%
    sudo apt-get install dialog -y > /dev/null 2>&1

    echo 50  # Atualiza para 100% após a atualização
) | whiptail --gauge "${label_install_tools}" 0 0 0

(
    echo 51  # Inicia em 0%
    sudo DEBIAN_FRONTEND=noninteractive apt install keyboard-configuration -y > /dev/null 2>&1

    echo 75  # Atualiza para 100% após a atualização
) | whiptail --gauge "${label_keyboard_settings}" 0 0 0
(
    echo 76  # Inicia em 0%
    sudo DEBIAN_FRONTEND=noninteractive apt install tzdata -y > /dev/null 2>&1 

    echo 100  # Atualiza para 100% após a atualização
	sudo apt remove whiptail -y > /dev/null 2>&1  # será necessário para não conflitar com o dialog da configuração de teclado e fuso horário
) | whiptail --gauge "${label_tzdata_settings}" 0 0 0

sudo dpkg-reconfigure keyboard-configuration
clear
sudo dpkg-reconfigure tzdata
clear

sudo apt install whiptail -y > /dev/null 2>&1
(
    echo 0  # Inicia em 0%
	echo "Oi"

	echo 10
    sudo apt-get install exo-utils --no-install-recommends -y > /dev/null 2>&1

    echo 16 
    sudo apt-get install tigervnc-standalone-server --no-install-recommends -y > /dev/null 2>&1
    
	echo 32
    sudo apt-get install tigervnc-common --no-install-recommends -y > /dev/null 2>&1
    
	echo 48
    sudo apt-get install tigervnc-tools --no-install-recommends -y > /dev/null 2>&1
    
	echo 64
    sudo apt-get install dbus-x11 --no-install-recommends -y > /dev/null 2>&1

	echo 72
	sudo apt install python3-gi -y > /dev/null 2>&1

	echo 80
	sudo apt install python3 -y > /dev/null 2>&1

	#echo 90

    echo 100  # Finaliza em 100%
    
 ) | whiptail --gauge "${label_system_setup}" 0 0 0

bash ~/config-environment.sh

bash ~/system-config.sh

chmod +x /usr/local/bin/vnc
chmod +x /usr/local/bin/vncpasswd
chmod +x /usr/local/bin/startvnc
chmod +x /usr/local/bin/stopvnc
chmod +x /usr/local/bin/startvncserver

rm -rf ~/system-config.sh
#rm -rf ~/config-environment.sh
rm -rf ~/.bash_profile' > $folder/root/.bash_profile

#sed -i "/sudo DEBIAN_FRONTEND=noninteractive apt install keyboard-configuration -y > \/dev\/null 2>&1/a sed -i 's|XKBMODEL=\"*\"|XKBMODEL=\"pc105\"|' /etc/default/keyboard" $folder/root/.bash_profile

#rm -rf ~/l10n*.sh
#rm -rf ~/fixed_variables.sh
bash $bin