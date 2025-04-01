#!/data/data/com.termux/files/usr/bin/bash
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"
system_icu_locale_code=$(getprop persist.sys.locale)

#=============================================================================================
# Instalação dos pacotes iniciais necessários para o funcionamento da ferramenta

# Lista de pacotes necessários
PACKAGES=("wget" "dialog" "proot" "debootstrap" "dbus")

# Função para verificar se um pacote está instalado
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Verifica se todos os pacotes estão instalados
ALL_INSTALLED=true
for pkg in "${PACKAGES[@]}"; do
    if ! is_installed "$pkg"; then
        ALL_INSTALLED=false
        break
    fi
done

# Executa a instalação apenas se algum pacote estiver faltando
if [ "$ALL_INSTALLED" = false ]; then
    apt install wget dialog proot debootstrap dbus -y &> /dev/null &
    PID=$!
    
    # Barra de progresso personalizada
    (
        for ((i=0; i<=100; i++)); do
            echo $i  # Atualiza a barra de progresso
            sleep 0.1  # Ajuste o tempo para simular o progresso
        done
    ) | dialog --gauge "Instalando pacotes..." 6 40 0
    
    # Aguarda o término do apt install
    wait $PID
else
    echo "Todos os pacotes já estão instalados."
fi

# Mensagem final
clear

#=============================================================================================
update_progress() {
    echo "$1"  # Envia a porcentagem para o dialog
    sleep 0.1  # Ajuste o tempo conforme necessário
}
(
    # Verifica e baixa fixed_variables.sh (0-33%)
    if [ ! -f "$HOME/fixed_variables.sh" ]; then
        curl -s -o "$HOME/fixed_variables.sh" "${extralink}/config/fixed_variables.sh"
        for i in {0..33}; do update_progress $i; done
    else
        for i in {0..33}; do update_progress $i; done  # Avança rapidamente se o arquivo já existe
    fi
    source $HOME/fixed_variables.sh
    # Verifica e baixa l10n_${locale}.sh (34-65%)
    if [ ! -f "$HOME/l10n_${system_icu_locale_code}.sh" ]; then
        curl -s -o "$HOME/l10n_${system_icu_locale_code}.sh" "${extralink}/config/locale/l10n_${system_icu_locale_code}.sh"
        for i in {34..65}; do update_progress $i; done
    else
        for i in {34..65}; do update_progress $i; done  # Avança rapidamente
    fi
    source $HOME/l10n_$system_icu_locale_code.sh
    # Verifica e baixa $distro_del (66-100%)
    if [ ! -f "$PREFIX/bin/$distro_del" ]; then
        curl -s -o "$HOME/$distro_del" "${extralink}/$distro_del"
        for i in {66..100}; do update_progress $i; done
        mv "$HOME/$distro_del" "$PREFIX/bin/$distro_del"
        chmod +x "$PREFIX/bin/$distro_del"
    else
        for i in {66..100}; do update_progress $i; done  # Avança rapidamente
    fi
) | dialog --gauge "${label_progress}" 0 0 0
clear

chmod +x "$HOME/fixed_variables.sh"
chmod +x "$HOME/l10n_${system_icu_locale_code}.sh"
source $HOME/fixed_variables.sh
source $HOME/l10n_$system_icu_locale_code.sh

# Escolher a versão do Debian a ser baixada
export PORT=1

OPTIONS=(1 "Bookworm 12.0 ($label_distro_stable)"
         2  "Bullseye ($label_distro_previous_version)")

CHOICE=$(dialog --clear \
				--title "$TITLE" \
				--menu "$MENU_operating_system_select" \
				$HEIGHT $WIDTH $CHOICE_HEIGHT \
				"${OPTIONS[@]}" \
				2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
		codinome="bookworm"
		folder=debian-bookworm
	;;
	2)
		codinome="bullseye"
		folder=debian-bullseye
	;;
esac

bin=start-debian.sh

# Caso a versão do debian já tenha sido baixada, não baixar novamente
if [ -d "$folder" ]; then
	first=1
	echo "${label_skip_download}"
fi

# Baixa
if [ "$first" != 1 ];then
	case `dpkg --print-architecture` in
	aarch64)
		archurl="arm64" ;;
	arm)
		archurl="armhf" ;;
	*)
		echo "unknown architecture"; exit 1 ;;
	esac
	debootstrap --arch=$archurl $codinome $folder http://deb.debian.org/debian > /dev/null 2>&1 &
	debootstrap_pid=$!
	(
		while kill -0 $debootstrap_pid >/dev/null 2>&1; do
			sleep $dialog_intervalo
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

	) | dialog --gauge "$label_debian_download" 0 0 0
	###
	if wait $debootstrap_pid; then
		echo "Instalação concluída com sucesso!"
		else
			echo "Erro durante a instalação do Debian!"
	fi

fi

mkdir -p debian-binds

echo "${label_start_script}"
cat > $bin <<- EOM
#!/bin/bash
#cd \$(dirname \$0)
cd $HOME
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --kill-on-exit"
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
command+=" -b /sdcard"
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
	echo "pasta criada"
fi


if [ ! -d "$folder/usr/share/icons/" ];then
	mkdir -p "$folder/usr/share/icons/"
	echo "pasta criada"
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
) | dialog --gauge "${label_progress}" 0 0 0

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
) | dialog --gauge "${label_progress}" 0 0 0


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
			) | dialog --gauge "${label_language_download}" 0 0 0
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
	echo 15
	wget --tries=20 "${extralink}/config/tigervnc/vnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
	# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done
	chmod +x $folder/usr/local/bin/vnc

	echo 30
	wget --tries=20 "${extralink}/config/tigervnc/vncpasswd" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
	# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done
	chmod +x $folder/usr/local/bin/vncpasswd

	echo 45
	wget --tries=20 "${extralink}/config/tigervnc/startvnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
	# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done
	chmod +x $folder/usr/local/bin/startvnc

	echo 60
	wget --tries=20 "${extralink}/config/tigervnc/stopvnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
	# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done
	chmod +x $folder/usr/local/bin/stopvnc

	echo 75
	wget --tries=20 "${extralink}/config/tigervnc/startvncserver" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
	# Extraindo a porcentagem do progresso do wget
		if [[ $line =~ ([0-9]+)% ]]; then
			percent=${BASH_REMATCH[1]}
			echo $percent  # Atualiza a barra de progresso
		fi
	done
	chmod +x $folder/usr/local/bin/startvncserver

	echo 100  # Finaliza
) | dialog --gauge "${label_language_download}" 0 0 0
clear

#Copiando arquivos para dentro do linux
mkdir -p $folder/root/.vnc
cp l10n_*.sh $folder/root/
cp l10n_*.sh $folder/root/.vnc
chmod +x $folder/root/l10n_*.sh
chmod +x $folder/root/.vnc/l10n_*.sh
cp fixed_variables.sh $folder/root/
chmod +x $folder/root/fixed_variables.sh

#echo "fixing shebang of $bin"
termux-fix-shebang $bin
#echo "making $bin executable"
chmod +x $bin

echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
touch $folder/root/.hushlogin
echo "#!/bin/bash
#echo 'deb http://deb.debian.org/debian stable main contrib non-free non-free-firmware
#deb http://security.debian.org/debian-security stable-security main contrib non-free
#deb http://deb.debian.org/debian stable-updates main contrib non-free
#deb http://ftp.debian.org/debian buster main
#deb http://ftp.debian.org/debian buster-updates main' >> /etc/apt/sources.list

echo '${label_alert_autoupdate_for_u}'
apt update -y > /dev/null 2>&1
apt install sudo wget -y > /dev/null 2>&1 
apt install dialog -y > /dev/null 2>&1

bash ~/locale*.sh

apt update -y > /dev/null 2>&1
clear
rm -rf ~/locale*.sh
rm -rf ~/.bash_profile
rm -rf ~/.hushlogin
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
		) | dialog --gauge "${label_config_environment_gui}" 0 0 0
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
		) | dialog --gauge "${label_config_environment_gui}" 0 0 0
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
		) | dialog --gauge "${label_config_environment_gui}" 0 0 0
		
		# Sem isso o gnome não funciona
		apt install dbus -y > /dev/null 2>&1

		# Parte da resolução do problema do gnome e do systemd
		if [ ! -d "/data/data/com.termux/files/usr/var/run/dbus" ];then
			mkdir /data/data/com.termux/files/usr/var/run/dbus # criar a pasta que o dbus funcionará
			echo "pasta criada"
		fi
		#mkdir /data/data/com.termux/files/usr/var/run/dbus # criar a pasta que o dbus funcionará
		rm -rf /data/data/com.termux/files/usr/var/run/dbus/pid #remover o pid para que o dbus-daemon funcione corretamente
		rm -rf system_bus_socket

		dbus-daemon --fork --config-file=/data/data/com.termux/files/usr/share/dbus-1/system.conf --address=unix:path=system_bus_socket #cria o arquivo

		if grep -q "<listen>tcp:host=localhost" /data/data/com.termux/files/usr/share/dbus-1/system.conf && # verifica se existe a linha com esse texto
		grep -q "<listen>unix:tmpdir=/tmp</listen>" /data/data/com.termux/files/usr/share/dbus-1/system.conf && # verifica se existe a linha com esse texto
		grep -q "<auth>ANONYMOUS</auth>" /data/data/com.termux/files/usr/share/dbus-1/system.conf && # verifica se existe a linha com esse texto
		grep -q "<allow_anonymous/>" /data/data/com.termux/files/usr/share/dbus-1/system.conf; then # verifica se existe a linha com esse texto
		echo ""
			else
				sed -i 's|<auth>EXTERNAL</auth>|<listen>tcp:host=localhost,bind=*,port=6667,family=ipv4</listen>\
				<listen>unix:tmpdir=/tmp</listen>\
				<auth>EXTERNAL</auth>\
				<auth>ANONYMOUS</auth>\
				<allow_anonymous/>|' /data/data/com.termux/files/usr/share/dbus-1/system.conf
		fi

		# É necessário repetir o processo toda vez que alterar o system.conf
		rm -rf /data/data/com.termux/files/usr/var/run/dbus/pid
		dbus-daemon --fork --config-file=/data/data/com.termux/files/usr/share/dbus-1/system.conf --address=unix:path=system_bus_socket
		sed -i "\|command+=\" -b $folder/root:/dev/shm\"|a command+=\" -b system_bus_socket:/run/dbus/system_bus_socket\"" $bin
		sed -i '1 a\rm -rf /data/data/com.termux/files/usr/var/run/dbus/pid \ndbus-daemon --fork --config-file=/data/data/com.termux/files/usr/share/dbus-1/system.conf --address=unix:path=system_bus_socket\n' $bin
	;;
esac

chmod +x $folder/root/config-environment.sh

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
		) | dialog --gauge "${label_progress}" 0 0 0
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
		) | dialog --gauge "${label_progress}" 0 0 0
		chmod +x l10n_$system_icu_locale_code.sh
		source "l10n_${system_icu_locale_code}.sh"
fi

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"
(
    echo 0  # Inicia em 0%
    echo "Aguarde, atualizando pacotes..."
    sudo apt update > /dev/null 2>&1
    
	echo 25  # Atualiza para 100% após a atualização
) | dialog --gauge "${label_find_update}" 0 0 0

(
    echo 26  # Inicia em 0%
    sudo DEBIAN_FRONTEND=noninteractive apt install keyboard-configuration -y > /dev/null 2>&1

    echo 50  # Atualiza para 100% após a atualização
) | dialog --gauge "${label_keyboard_settings}" 0 0 0
(
    echo 75  # Inicia em 0%
    sudo DEBIAN_FRONTEND=noninteractive apt install tzdata -y > /dev/null 2>&1 

    echo 100  # Atualiza para 100% após a atualização
	sudo apt autoremove whiptail -y > /dev/null 2>&1
) | dialog --gauge "${label_tzdata_settings}" 0 0 0

sudo dpkg-reconfigure keyboard-configuration
clear
sudo dpkg-reconfigure tzdata
clear
sudo apt install dialog -y > /dev/null 2>&1

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
    
 ) | dialog --gauge "${label_system_setup}" 0 0 0

chmod +x /usr/local/bin/vnc
chmod +x /usr/local/bin/vncpasswd
chmod +x /usr/local/bin/startvnc
chmod +x /usr/local/bin/stopvnc
chmod +x /usr/local/bin/startvncserver

bash ~/system-config.sh

bash ~/config-environment.sh


if [ ! -e "~/start-environment.sh" ];then
	bash ~/start-environment.sh
fi

rm -rf ~/system-config.sh
rm -rf ~/config-environment.sh
rm -rf ~/.bash_profile
exit' > $folder/root/.bash_profile
bash $bin

#rm -rf ~/l10n*.sh
#rm -rf ~/fixed_variables.sh

# Cria uma gui de inicialização
sed -i '\|command+=" /bin/bash --login"|a command+=" -b /usr/local/bin/startvncserver"' $bin

cp "$bin" "$PREFIX/bin/${bin%.sh}" #isso permite que o comando seja iniciado sem o uso do bash ou ./

rm -rf $HOME/distrolinux-install.sh
rm -rf $HOME/start-distro.sh
bash $bin