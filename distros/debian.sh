#!/data/data/com.termux/files/usr/bin/bash
source "$PREFIX/bin/andistro_files/fixed_variables.sh"
bin="start-debian.sh"
codinome="bookworm"
folder="debian-bookworm"

#=============================================================================================
# Caso a versão do debian já tenha sido baixada, não baixar novamente
if [ -d "$folder" ]; then
	first=1
	echo "${label_skip_download}"
fi

dialog --infobox "Etapa 3 \nBaixar o sistema..." 5 50
sleep 4
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
	error_code="DW001deb"
	show_progress_dialog wget "${label_debian_download}" 1 -O $folder.tar.xz "${extralink}/distros/files/debian-${codinome}-${archurl}.tar.xz"
	sleep 2
	show_progress_dialog extract "${label_debian_download_extract}" "$HOME/$folder.tar.xz" 
	sleep 2
fi

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

if [ ! -d "$folder/root/.vnc/" ];then
	mkdir -p $folder/root/.vnc/
	echo "pasta criada"
fi

show_progress_dialog wget-labeled "${label_progress}" 3 \
  "${label_progress}" -O "$folder/root/system-config.sh" "${extralink}/config/system-config.sh" \
  "${label_wallpaper_download}" -P "$folder/usr/share/backgrounds" "${extralink}/config/wallpapers/unsplash/john-towner-JgOeRuGD_Y4.jpg" \
  "${label_wallpaper_download}" -P "$folder/usr/share/backgrounds" "${extralink}/config/wallpapers/unsplash/wai-hsuen-chan-DnmMLipPktY.jpg"

chmod +x "$folder/root/system-config.sh"

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
		#sed -i 's|command+=" LANG=C.UTF-8"|command+=" LANG=pt_BR.UTF-8"|' $bin
		error_code="LG001br"
		show_progress_dialog "wget" "${label_language_download}" 1 -P "$folder/root/" "${extralink}/config/locale/locale_pt-BR.sh"
		sleep 5
		exit_erro
		chmod +x $folder/root/locale_pt-BR.sh

		;;
	2)
		echo ""
	;;
esac
dialog --infobox "Etapa 8 \nBaixar arquivos do VNC..." 5 50
sleep 4
error_code="VNC001x"
show_progress_dialog "wget" "${label_progress}" 5 \
  -P "$folder/usr/local/bin" \
  "${extralink}/config/tigervnc/vnc" \
  "${extralink}/config/tigervnc/vncpasswd" \
  "${extralink}/config/tigervnc/startvnc" \
  "${extralink}/config/tigervnc/stopvnc" \
  "${extralink}/config/tigervnc/startvncserver"

exit_erro

chmod +x $folder/usr/local/bin/vnc
chmod +x $folder/usr/local/bin/vncpasswd
chmod +x $folder/usr/local/bin/startvnc
chmod +x $folder/usr/local/bin/stopvnc
chmod +x $folder/usr/local/bin/startvncserver
clear

#Copiando arquivos para dentro do linux

#move para o bin
cp "$PREFIX/bin/andistro_files/l10n_*.sh" $folder/usr/local/bin
cp "$PREFIX/bin/andistro_files/fixed_variables.sh" $folder/usr/local/bin

#echo "fixing shebang of $bin"
termux-fix-shebang $bin
#echo "making $bin executable"
chmod +x $bin

dialog --infobox "Etapa 9 \nVamos entrar no sistema agora..." 5 50
sleep 4
echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
touch $folder/root/.hushlogin
echo "#!/bin/bash
source "/usr/local/bin/fixed_variables.sh"
#echo 'deb http://deb.debian.org/debian stable main contrib non-free non-free-firmware
#deb http://security.debian.org/debian-security stable-security main contrib non-free
#deb http://deb.debian.org/debian stable-updates main contrib non-free
#deb http://ftp.debian.org/debian buster main
#deb http://ftp.debian.org/debian buster-updates main' >> /etc/apt/sources.list

dialog --infobox 'Etapa 10 \nbaixar pacotes necessários...' 5 50
sleep 4
echo '${label_alert_autoupdate_for_u}'
apt update -y > /dev/null 2>&1
total_steps=7
{
    #1 Verifica se o sudo está instalado
    if ! dpkg -l | grep -qw sudo; then
        apt install sudo -y
    fi
    ((current_step++))
    update_progress "$current_step" "$total_steps"; sleep 0.1

	#2 Verifica se o wget está instalado
    if ! dpkg -l | grep -qw wget; then
        apt install wget -y
    fi
    ((current_step++))
    update_progress "$current_step" "$total_steps"; sleep 0.1

	#3 Verifica se o dialog está instalado
    if ! dpkg -l | grep -qw dialog; then
        apt install dialog -y
    fi
    ((current_step++))
    update_progress "$current_step" "$total_steps"; sleep 0.1

	#4 Verifica se o xz-utils está instalado
    if ! dpkg -l | grep -qw xz-utils; then
        apt install xz-utils -y
    fi
    ((current_step++))
    update_progress "$current_step" "$total_steps"; sleep 0.1

	#5 Verifica se o unzip está instalado
    if ! dpkg -l | grep -qw unzip; then
        apt install unzip -y
    fi
    ((current_step++))
    update_progress "$current_step" "$total_steps"; sleep 0.1

	#6 Verifica se o tar está instalado
    if ! dpkg -l | grep -qw tar; then
        apt install tar -y
    fi
    ((current_step++))
    update_progress "$current_step" "$total_steps"; sleep 0.1

    #7 Verifica se o curl está instalado
    if ! dpkg -l | grep -qw curl; then
        apt install curl -y
    fi
    ((current_step++))
    update_progress "$current_step" "$total_steps"; sleep 0.1

	echo
}
clear
dialog --infobox 'Etapa 11 \nConfigurar o idioma...' 5 50
sleep 4
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
		echo "LXDE UI"
		show_progress_dialog "wget" "${label_config_environment_gui}" 1 -O "$folder/root/config-environment.sh" "${extralink}/config/environment/lxde/config.sh"
	;;
	2)	
		echo "XFCE UI"
		show_progress_dialog "wget" "${label_config_environment_gui}" 1 -O "$folder/root/config-environment.sh" "${extralink}/config/environment/xcfe4/config.sh"
	;;
	3)
		echo "Gnome UI"
		show_progress_dialog "wget" "${label_config_environment_gui}" 1 -O "$folder/root/config-environment.sh" "${extralink}/config/environment/gnome/config.sh"

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
source "/usr/local/bin/fixed_variables.sh"

show_progress_dialog apt-labeled 4 \
	"${label_find_update}" 'sudo apt update -y ' \
	"${label_keyboard_settings}" 'sudo apt autoremove whiptail -y' \
	"${label_keyboard_settings}" 'sudo apt install keyboard-configuration -y' \
	"${label_tzdata_settings}" 'sudo apt install tzdata -y'

apts=(
	"apt-get install exo-utils --no-install-recommends -y"
	"apt-get install tigervnc-standalone-server --no-install-recommends -y"
	"apt-get install tigervnc-common --no-install-recommends -y"
	"apt-get install tigervnc-tools --no-install-recommends -y"
	"apt-get install dbus-x11 --no-install-recommends -y"
	"apt install python3-gi -y"
	"apt install python3 -y"
)
show_progress_dialog "steps" "$label_system_setup" 7 "${apts[@]}"

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

# Cria uma gui de inicialização
sed -i '\|command+=" /bin/bash --login"|a command+=" -b /usr/local/bin/startvncserver"' $bin
cp "$bin" "$PREFIX/bin/${bin%.sh}" #isso permite que o comando seja iniciado sem o uso do bash ou ./
rm -rf $HOME/distrolinux-install.sh
rm -rf $HOME/start-distro.sh
bash $bin