#!/bin/bash

extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

if [[ "$system_icu_locale_code" == "pt-BR" || "$LANG" == "pt_BR.UTF-8" ]]; then

    #label_system_info="Informações do seu sistema"
    #label_android_version="Versão do Android"
    #label_device_manufacturer="Marca"
    #label_device_model="Modelo"
    #label_device_hardware="Chipset"
    #label_android_architecture="Arquitetura"
    #label_android_architecture_unknow="Arquitetura não identificada"
    #label_system_country="Região"
    #label_system_country_iso="Abreviação"
    #label_system_icu_locale_code="Código do idioma"
    #label_system_timezone="Fuso horário"
    #desc_system_info="Use o comando ./sys-info para poder ver essas informações novamente."
    #label_progress="Em andamento..."

    # Sobre downloads
    #label_install_script_download="Baixando script de instalação..."
    #label_skip_download="Pulando o download"
    #label_decopressing_rootfs="Descompactando arquivos..."
    #label_wallpaper_download="Baixando wallpaper..."

    #Download do sistema
    #label_ubuntu_download="Baixando o Ubuntu..."

    #TITULO DO MENU DE DIALOGO
    #MENU_operating_system_selectt="Escolha o sistema operacional que será instalado: "
    #MENU_language_select="Idioma a instalar: "
    #label_language_download="Downloading your language settings...


else
    echo ""
fi
