#!/data/data/com.termux/files/usr/bin/bash
#🚀
pkg install wget curl proot tar dialog whiptail -y
clear
#Logs do sistema
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"
android_version=$(getprop ro.build.version.release) #versão do Android
android_architecture=$(getprop ro.product.cpu.abi) #Arquitetura do aparelho
device_manufacturer=$(getprop ro.product.manufacturer) #fabricante
device_model=$(getprop ro.product.model) # modelo
device_model_complete=$(getprop ril.product_code) #código do modelo

device_hardware=$(getprop ro.hardware.chipname)
system_country=$(getprop ro.csc.country_code)
system_country_iso=$(getprop ro.csc.countryiso_code)
system_icu_locale_code=$(getprop persist.sys.locale)
system_timezone=$(getprop persist.sys.timezone)
GMT_date=$(date +"%Z")

#Whilptail dialogs
whiptail_total_time=2
## Configurar o intervalo de atualização da barra de progresso
whiptail_intervalo=1
## Número de etapas na barra de progresso
steps=$((whiptail_total_time / whiptail_intervalo))

if [ "$system_country" = "Brazil" ]; then
  system_country="Brasil"
fi
clear

system_info="Informações do seu sistema

Versão do Android: ${android_version}

Marca: ${device_manufacturer}
Modelo: ${device_model} / ${device_model_complete}

Chipset: ${device_hardware}
Arquitetura: ${android_architecture}

Região: ${system_country}
Abreviação: ${system_country_iso}
Código do idioma: ${system_icu_locale_code}
Seu fuso horário: (GMT${GMT_date}:00) ${system_timezone}

Use o comando ./sys-info para poder ver essas informações novamente.
"

wget --tries=20 "${extralink}/sys-info" -O sys-info > /dev/null 2>&1 &
chmod +x sys-info



# textos traduzidos
## Em andamento
if [ "$system_icu_locale_code" = "pt-BR" ]; then
      andamento="Em andamento..."
      else
        andamento="In progress..."
    fi

####################

# Exibir a caixa de progresso
(
  progress=0
  while [ $progress -lt $steps ]; do
    sleep $whiptail_intervalo
    echo "Em andamento..."
    echo "$((++progress * 100 / steps))"
  done
  echo "Em andamento..."
  echo "100"
  sleep 2
  clear
) | whiptail --gauge "${system_info}" 0 0 0

# Limpar a tela
clear

# Dialogs
export USER=$(whoami)
HEIGHT=0
WIDTH=70
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
wget --tries=20 "${extralink}/distros/ubuntu.sh" -O start-distro.sh > /dev/null 2>&1 &
(
  while pkill -0 wget >/dev/null 2>&1; do
    sleep $whiptail_intervalo
    if [ "$system_icu_locale_code" = "pt-BR" ]; then
      echo "Em andamento..."
      else
        echo "In progress..."
    fi
    
    echo "$((++percentage))"
  done
  if [ "$system_icu_locale_code" = "pt-BR" ]; then
      echo "Em andamento..."
      else
        echo "In progress..."
    fi
  echo "100"
  sleep 2
) | whiptail --gauge $andamento 0 0 0

# Limpar a tela
clear
;;

esac

chmod +x start-distro.sh
bash start-distro.sh