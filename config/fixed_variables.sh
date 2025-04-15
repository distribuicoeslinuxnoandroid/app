#!/bin/bash
extralink="https://raw.githubusercontent.com/andistro/app/main"

#dialog
dialog_total_time=2 ## Configurar o intervalo de atualização da barra de progresso
dialog_intervalo=1 ## Número de etapas na barra de progresso
steps=$((dialog_total_time / dialog_intervalo))
percentage=0

export USER=$(whoami)
HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=5
export PORT=1

# Verifica se o comando getprop existe antes de executar
if command -v getprop > /dev/null 2>&1; then
    android_version=$(getprop ro.build.version.release 2>/dev/null)         # Versão do Android
    android_architecture=$(getprop ro.product.cpu.abi 2>/dev/null)         # Arquitetura do aparelho
    device_manufacturer=$(getprop ro.product.manufacturer 2>/dev/null)     # Fabricante
    device_model=$(getprop ro.product.model 2>/dev/null)                   # Modelo
    device_model_complete=$(getprop ril.product_code 2>/dev/null)          # Código do modelo

    device_hardware=$(getprop ro.hardware.chipname 2>/dev/null)            # Chipset Processador
    system_country=$(getprop ro.csc.country_code 2>/dev/null)              # País
    system_country_iso=$(getprop ro.csc.countryiso_code 2>/dev/null)       # Abreviação do País
    system_icu_locale_code=$(getprop persist.sys.locale 2>/dev/null)       # Locale
    system_timezone=$(getprop persist.sys.timezone 2>/dev/null)            # Timezone
else
    system_icu_locale_code=$(echo $LANG | sed 's/\..*//' | sed 's/_/-/')
fi


#Formato GMT
GMT_date=$(date +"%Z":00)

#cur=`pwd`

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"


# Função para atualizar a barra de progresso
# update_progress() precisa ser definido antes de ser usado

update_progress() {
    current_step=$1
    total_steps=$2

    percent=$((current_step * 100 / total_steps))
    bar_length=30
    filled_length=$((percent * bar_length / 100))
    empty_length=$((bar_length - filled_length))

    filled_bar=$(printf "%${filled_length}s" | tr " " "=")
    empty_bar=$(printf "%${empty_length}s" | tr " " " ")

    printf "\r[%s%s] %3d%%" "$filled_bar" "$empty_bar" "$percent"
}

# Valores padrão. Toque inserir as váriáveis antes de cada código que usar essa barra de progresso.
total_steps=10  # Número total de etapas que você quer monitorar
current_step=0

# Usar o:
# ((current_step++))
# update_progress "$current_step" "$total_steps"; sleep 0.1
# Abaixo do código dentro do {} para que haja uma etapa de progresso