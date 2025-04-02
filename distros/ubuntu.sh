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
) | dialog --gauge "${label_progress}" 6 40 0
clear

chmod +x "$HOME/fixed_variables.sh"
chmod +x "$HOME/l10n_${system_icu_locale_code}.sh"
source $HOME/fixed_variables.sh
source $HOME/l10n_$system_icu_locale_code.sh

bin=start-debian.sh
codinome="noble"
folder=ubuntu-noble
binds=ubuntu-binds

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
	debootstrap --arch=$archurl $codinome $folder http://ftp.ubuntu.com/ubuntu/ > /dev/null 2>&1 &

    wget "https://partner-images.canonical.com/core/${codinome}/current/ubuntu-${codinome}-core-cloudimg-${archurl}-root.tar.gz" -O $cloudimagename  >/dev/null 2>&1 &
    #GUI
    (
        while pkill -0 wget >/dev/null 2>&1; do
        sleep $whiptail_intervalo
        echo "${label_ubuntu_download}"
        echo "$((++percentage))"
        done
        echo "${label_ubuntu_download}"
        echo "100"
        sleep 2
    ) | dialog --gauge "${label_ubuntu_download}" 6 40 0
fi

mkdir -p $binds
mkdir -p ${folder}/proc/fakethings

if [ ! -f "${cur}/${folder}/proc/fakethings/stat" ]; then
	cat <<- EOF > "${cur}/${folder}/proc/fakethings/stat"
	cpu  5502487 1417100 4379831 62829678 354709 539972 363929 0 0 0
	cpu0 611411 171363 667442 7404799 61301 253898 205544 0 0 0
	cpu1 660993 192673 571402 7853047 39647 49434 29179 0 0 0
	cpu2 666965 186509 576296 7853110 39012 48973 26407 0 0 0
	cpu3 657630 183343 573805 7863627 38895 48768 26636 0 0 0
	cpu4 620516 161440 594973 7899146 39438 47605 26467 0 0 0
	cpu5 610849 155665 594684 7912479 40258 46870 26044 0 0 0
	cpu6 857685 92294 387182 8096756 46609 22110 12364 0 0 0
	cpu7 816434 273809 414043 7946709 49546 22311 11284 0 0 0
	intr 601715486 0 0 0 0 70612466 0 2949552 0 93228 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 12862684 625329 10382717 16209 55315 8510 0 0 0 0 11 11 13 270 192 40694 95 7 0 0 0 36850 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 286 6378 0 0 0 54 0 3239423 2575191 82725 0 0 127 0 0 0 1791277 850609 20 9076504 0 301 0 0 0 0 0 3834621 0 0 0 0 0 0 0 0 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 806645 0 0 0 0 0 7243 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2445850 52 1783 0 0 5091520 0 0 0 3 0 0 0 0 0 5475 0 198001 0 2 42 1289224 0 2 202483 4 0 8390 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3563336 4202122 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 1 0 1 0 0 1 0 1 0 17948 0 0 612 0 0 0 0 2103 0 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 10 0 0 0 0 0 0 0 11 11 12 0 12 0 52 752 0 0 0 0 0 0 0 743 0 14 0 0 12 0 0 1863 229 0 464 0 0 0 0 0 0 8588 97 7236426 92766 622 31 0 0 0 18 4 4 0 5 0 0 116013 7 0 0 752406
	ctxt 826091808
	btime 1611513513
	processes 288493
	procs_running 1
	procs_blocked 0
	softirq 175407567 14659158 51739474 28359 5901272 8879590 0 11988166 46104015 0 36107533
	EOF
fi

if [ ! -f "${cur}/${folder}/proc/fakethings/version" ]; then
	cat <<- EOF > "${cur}/${folder}/proc/fakethings/version"
	Linux version 5.4.0-faked (distribuicoeslinuxnoandroid@fakeandroid) (gcc version 4.9.x (Fake Distribuicoes Linux no Android /proc/version) ) #1 SMP PREEMPT Tue Apr 01 00:00:00 BRT 2025
	EOF
fi

if [ ! -f "${cur}/${folder}/proc/fakethings/vmstat" ]; then
	cat <<- EOF > "${cur}/${folder}/proc/fakethings/vmstat"
	nr_free_pages 15717
	nr_zone_inactive_anon 87325
	nr_zone_active_anon 259521
	nr_zone_inactive_file 95508
	nr_zone_active_file 57839
	nr_zone_unevictable 58867
	nr_zone_write_pending 0
	nr_mlock 58867
	nr_page_table_pages 24569
	nr_kernel_stack 49552
	nr_bounce 0
	nr_zspages 80896
	nr_free_cma 0
	nr_inactive_anon 87325
	nr_active_anon 259521
	nr_inactive_file 95508
	nr_active_file 57839
	nr_unevictable 58867
	nr_slab_reclaimable 17709
	nr_slab_unreclaimable 47418
	nr_isolated_anon 0
	nr_isolated_file 0
	workingset_refault 33002180
	workingset_activate 5498395
	workingset_restore 2354202
	workingset_nodereclaim 140006
	nr_anon_pages 344014
	nr_mapped 193745
	nr_file_pages 218441
	nr_dirty 0
	nr_writeback 0
	nr_writeback_temp 0
	nr_shmem 1880
	nr_shmem_hugepages 0
	nr_shmem_pmdmapped 0
	nr_anon_transparent_hugepages 0
	nr_unstable 0
	nr_vmscan_write 8904094
	nr_vmscan_immediate_reclaim 139732
	nr_dirtied 8470080
	nr_written 16835370
	nr_indirectly_reclaimable 8273152
	nr_unreclaimable_pages 130861
	nr_dirty_threshold 31217
	nr_dirty_background_threshold 15589
	pgpgin 198399484
	pgpgout 31742368
	pgpgoutclean 45542744
	pswpin 3843200
	pswpout 8903884
	pgalloc_dma 192884869
	pgalloc_normal 190990320
	pgalloc_movable 0
	allocstall_dma 0
	allocstall_normal 3197
	allocstall_movable 1493
	pgskip_dma 0
	pgskip_normal 0
	pgskip_movable 0
	pgfree 384653565
	pgactivate 34249517
	pgdeactivate 44271435
	pglazyfree 192
	pgfault 46133667
	pgmajfault 5568301
	pglazyfreed 0
	pgrefill 55909145
	pgsteal_kswapd 58467386
	pgsteal_direct 255950
	pgscan_kswapd 86628315
	pgscan_direct 415889
	pgscan_direct_throttle 0
	pginodesteal 18
	slabs_scanned 31242197
	kswapd_inodesteal 1238474
	kswapd_low_wmark_hit_quickly 11637
	kswapd_high_wmark_hit_quickly 5411
	pageoutrun 32167
	pgrotated 213328
	drop_pagecache 0
	drop_slab 0
	oom_kill 0
	pgmigrate_success 729722
	pgmigrate_fail 450
	compact_migrate_scanned 43510584
	compact_free_scanned 248175096
	compact_isolated 1494774
	compact_stall 6
	compact_fail 3
	compact_success 3
	compact_daemon_wake 9438
	compact_daemon_migrate_scanned 43502436
	compact_daemon_free_scanned 248107303
	unevictable_pgs_culled 66418
	unevictable_pgs_scanned 0
	unevictable_pgs_rescued 8484
	unevictable_pgs_mlocked 78830
	unevictable_pgs_munlocked 8508
	unevictable_pgs_cleared 11455
	unevictable_pgs_stranded 11455
	swap_ra 0
	swap_ra_hit 7
	speculative_pgfault 221449963
	EOF
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
if [ -n "\$(ls -A $binds)" ]; then
    for f in $binds/* ;do
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
) | dialog --gauge "${label_progress}" 6 40 0

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
) | dialog --gauge "${label_progress}" 6 40 0


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
			) | dialog --gauge "${label_language_download}" 6 40 0
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
) | dialog --gauge "${label_language_download}" 6 40 0
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
		) | dialog --gauge "${label_config_environment_gui}" 6 40 0
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
		) | dialog --gauge "${label_config_environment_gui}" 6 40 0
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
		) | dialog --gauge "${label_config_environment_gui}" 6 40 0
		
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

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"
(
    echo 0  # Inicia em 0%
    echo "Aguarde, atualizando pacotes..."
    sudo apt update > /dev/null 2>&1
    
	echo 25  # Atualiza para 100% após a atualização
) | dialog --gauge "${label_find_update}" 6 40 0

(
    echo 26  # Inicia em 0%
    sudo DEBIAN_FRONTEND=noninteractive apt install keyboard-configuration -y > /dev/null 2>&1

    echo 50  # Atualiza para 100% após a atualização
) | dialog --gauge "${label_keyboard_settings}" 6 40 0
(
    echo 75  # Inicia em 0%
    sudo DEBIAN_FRONTEND=noninteractive apt install tzdata -y > /dev/null 2>&1 

    echo 100  # Atualiza para 100% após a atualização
	sudo apt autoremove whiptail -y > /dev/null 2>&1
) | dialog --gauge "${label_tzdata_settings}" 6 40 0

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
    
 ) | dialog --gauge "${label_system_setup}" 6 40 0

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