#!/bin/bash
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

#WHIPTAIL

whiptail_total_time=2 ## Configurar o intervalo de atualização da barra de progresso
whiptail_intervalo=1 ## Número de etapas na barra de progresso
steps=$((whiptail_total_time / whiptail_intervalo))

export USER=$(whoami)
HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=5
export PORT=1


# Variaveis

# Comandos exclusivos para Android
android_version=$(getprop ro.build.version.release) #Versão do Android
android_architecture=$(getprop ro.product.cpu.abi) #Arquitetura do aparelho
device_manufacturer=$(getprop ro.product.manufacturer) #Fabricante
device_model=$(getprop ro.product.model) # Modelo getprop
device_model_complete=$(getprop ril.product_code) #Código do modelo

device_hardware=$(getprop ro.hardware.chipname) #Chipset Processador
system_country=$(getprop ro.csc.country_code) #País
system_country_iso=$(getprop ro.csc.countryiso_code) #Abreviação do País
system_icu_locale_code=$(getprop persist.sys.locale) #
system_timezone=$(getprop persist.sys.timezone)

#Formato GMT
GMT_date=$(date +"%Z":00)

cur=`pwd`

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"