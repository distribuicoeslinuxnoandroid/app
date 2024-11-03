#!/data/data/com.termux/files/usr/bin/bash
#🚀
apt install wget curl proot tar dialog whiptail -y > /dev/null 2>&1 &
clear
#Logs do sistema
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"
system_icu_locale_code=$(getprop persist.sys.locale)

if [ -f "fixed_variables.sh" ]; then
	source fixed_variables.sh
	else
		wget --tries=20 "${extralink}/config/fixed_variables.sh" > /dev/null 2>&1 &
		chmod +x fixed_variables.sh
		source fixed_variables.sh
fi

if [ -f "l10n_${system_icu_locale_code}.sh" ]; then
	source l10n_$system_icu_locale_code.sh
	else
		wget --tries=20 "${extralink}/config/locale/l10n_${system_icu_locale_code}.sh" > /dev/null 2>&1 &
		chmod +x l10n_$system_icu_locale_code.sh
    source l10n_$system_icu_locale_code.sh
fi
sleep 1

system_info="${label_system_info}

${label_android_version}: ${android_version}

${label_device_manufacturer}: ${device_manufacturer}
${label_device_model} / ${device_model_complete}

${label_device_hardware}: ${device_hardware}
${label_android_architecture}: ${android_architecture}

${label_system_country}: ${system_country}
${label_system_country_iso}: ${system_country_iso}
${label_system_icu_locale_code}: ${system_icu_locale_code}
${label_system_timezone}: (GMT${GMT_date}) ${system_timezone}

${desc_system_info}
"

wget --tries=20 "${extralink}/sys-info" -O sys-info > /dev/null 2>&1 &
chmod +x sys-info

# Exibir a caixa de progresso
(
  progress=0
  while [ $progress -lt $steps ]; do
    sleep $whiptail_intervalo
    echo "${label_progress}"
    echo "$((++progress * 100 / steps))"
  done
  echo "${label_progress}"
  echo "100"
  sleep 2
  clear
) | whiptail --gauge "${system_info}" 0 0 0

# Limpar a tela
clear

OPTIONS=(1 "Ubuntu")

CHOICE=$(dialog --clear \
                --title "$TITLE" \
                --menu "$MENU_operating_system_select" \
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
      
      echo "${label_progress}"
      
      echo "$((++percentage))"
    done

    echo "${label_progress}"

    echo "75"
    sleep 2
  ) | whiptail --gauge "${label_progress}" 0 0 0

  clear
;;

esac

chmod +x start-distro.sh
bash start-distro.sh