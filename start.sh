#!/data/data/com.termux/files/usr/bin/bash
#🚀
pkg install wget curl proot tar dialog -y

extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app"
system_icu_locale_code=$(getprop persist.sys.locale)


# Dialogs
export USER=$(whoami)
HEIGHT=0
WIDTH=0
CHOICE_HEIGHT=5
MENU="Choose any of the following options: "
export PORT=1
if [ "$system_icu_locale_code" = "pt-BR" ]; then
MENU="Escolha algumas das seguintes opções: "
else
MENU="Choose any of the following options: "
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