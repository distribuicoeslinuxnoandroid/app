#!/data/data/com.termux/files/usr/bin/bash
#🚀
pkg --check-mirror update
pkg install wget curl proot tar dialog -y

clear
#Logs do sistema
android_version=$(getprop ro.build.version.release)
android_architecture=$(getprop ro.product.cpu.abi)
system_icu_locale_code=$(getprop persist.sys.locale)


echo ""
echo -e "\e[1;107;30;mInformações do seu sistema\e[0m"
echo ""
echo -e "\033[1;32mVersão do Android:\033[0m $android_version"
echo -e "\033[1;35mArquitetura:\033[0m $android_architecture"
echo -e "\033[1;33mIdioma:\033[0m: $system_icu_locale_code"
sleep 5
clear

extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"



# Dialogs
export USER=$(whoami)
HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=5

export PORT=1


if [ "$system_icu_locale_code" = "pt-BR" ]; then
MENU="Escolha o sistema operacional que será instalado: "
else
MENU="Choose the operating system to be installed: "
fi
OPTIONS=(1 "Ubuntu")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
1)
echo "Ubuntu"
wget --tries=20 $extralink/distros/ubuntu.sh -O start-distro.sh
;;

esac

chmod +x start-distro.sh
bash start-distro.sh

# sleep 2 pausa a execução por 2 segundos