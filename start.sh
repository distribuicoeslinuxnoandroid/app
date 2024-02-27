#!/data/data/com.termux/files/usr/bin/bash
#🚀
pkg install wget curl proot tar dialog -y
clear
#Logs do sistema
android_version=$(getprop ro.build.version.release)
android_architecture=$(getprop ro.product.cpu.abi)
device_manufacturer=$(getprop ro.product.manufacturer)
device_model=$(getprop ro.product.model)
device_model_complete=$(getprop ril.product_code)

device_hardware=$(getprop ro.hardware.chipname)
system_country=$(getprop ro.csc.country_code)
system_country_iso=$(getprop ro.csc.countryiso_code)
system_icu_locale_code=$(getprop persist.sys.locale)
system_timezone=$(getprop persist.sys.timezone)

clear
echo ""
echo -e "\033[1;4;37mInformações do seu sistema\033[0m"
echo ""
echo -e "\033[1;29mVersão do Android:\033[0m ${android_version}" #Versão do sistema
echo ""
echo -e "\033[1;29mMarca:\033[0m ${device_manufacturer}" #Marca
echo -e "\033[1;29mModelo:\033[0m ${device_model} / ${device_model_complete}" #Modelo


echo ""
echo -e "\033[1;29mChipset:\033[0m ${device_hardware}" #SoC
echo -e "\033[1;29mArquitetura:\033[0m ${android_architecture}" #Arquitetura do processador
echo ""
echo -e "\033[1;29mRegião:\033[0m ${system_country}" #País
echo -e "\033[1;29mAbreviação:\033[0m ${system_country_iso}" #Abreviação nome do país
echo -e "\033[1;29mCódigo do idioma:\033[0m ${system_icu_locale_code}" #Idioma 
echo -e "\033[1;29mSeu fuso horário:\033[0m ${system_timezone}" #Fuso horário
echo ""
echo ""
for i in {10..1}; do
  echo -ne "\rFecha em: [$i]s"
  sleep 1
done
#sleep 10
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