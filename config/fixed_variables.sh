#!/bin/bash
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

#WHIPTAIL

whiptail_total_time=2 ## Configurar o intervalo de atualização da barra de progresso
whiptail_intervalo=1 ## Número de etapas na barra de progresso
steps=$((whiptail_total_time / whiptail_intervalo))
percentage=0

export USER=$(whoami)
HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=5
export PORT=1


# Variaveis

# Comandos exclusivos para Android
android_version=$(getprop ro.build.version.release) > /dev/null 2>&1 #Versão do Android
android_architecture=$(getprop ro.product.cpu.abi) > /dev/null 2>&1 #Arquitetura do aparelho
device_manufacturer=$(getprop ro.product.manufacturer) > /dev/null 2>&1 #Fabricante
device_model=$(getprop ro.product.model) > /dev/null 2>&1 # Modelo getprop
device_model_complete=$(getprop ril.product_code) > /dev/null 2>&1 #Código do modelo

device_hardware=$(getprop ro.hardware.chipname) > /dev/null 2>&1 #Chipset Processador
system_country=$(getprop ro.csc.country_code) > /dev/null 2>&1 #País
system_country_iso=$(getprop ro.csc.countryiso_code) > /dev/null 2>&1 #Abreviação do País
system_icu_locale_code=$(getprop persist.sys.locale) > /dev/null 2>&1 #
system_timezone=$(getprop persist.sys.timezone) > /dev/null 2>&1

#Formato GMT
GMT_date=$(date +"%Z":00)

cur=`pwd`

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"