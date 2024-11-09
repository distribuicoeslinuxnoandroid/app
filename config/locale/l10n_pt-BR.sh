#!/bin/bash

extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

if grep -q "LANG=pt_BR.UTF-8" ~/.bashrc; then
  export LANGUAGE=pt_BR.UTF-8
  export LANG=pt_BR.UTF-8
  export LC_ALL=pt_BR.UTF-8
  else
    echo ""
fi

#if [[ "$system_icu_locale_code" == "pt-BR" || "$LANG" == "pt_BR.UTF-8"|| "$(grep -E '^export LANG=pt_BR.UTF-8' ~/.bashrc)" ]]; then

    label_system_info="Informações do seu sistema"
    label_android_version="Versão do Android"
    label_device_manufacturer="Marca"
    label_device_model="Modelo"
    label_device_hardware="Chipset"
    label_android_architecture="Arquitetura"
    label_android_architecture_unknow="Arquitetura não identificada"
    label_system_country="Região"
    label_system_country_iso="Abreviação"
    label_system_icu_locale_code="Código do idioma"
    label_system_timezone="Fuso horário"
    desc_system_info="Use o comando ./sys-info para poder ver essas informações novamente."
    label_progress="Em andamento..."
    label_language_download="Baixando as configurações do seu idioma..."
    label_create_boot="Criando a inicialização..."
    label_alert_autoupdate_for_u="Estou me atualizando para que o sistema que bom para você."
    label_find_update="Procurando atualizações..."
    label_update="Atualizando o sistema..."
    label_install_tools="Instalando ferramentas..."
    label_system_setup="Configurando o sistema..."
    label_system_language="Configurando idioma..."
    label_updating_packages="Aguarde, atualizando pacotes..."
    label_keyboard_settings="Trazendo as configurações do teclado...."
    label_tzdata_settings="Trazendo as configurações de teclado e fuso horário...."
    label_config_environment_gui="Baixando as configurações necessárias..."

    # Sobre downloads
    label_install_script_download="Baixando script de instalação..."
    label_skip_download="Pulando o download"
    label_decopressing_rootfs="Descompactando arquivos..."
    label_wallpaper_download="Baixando wallpaper..."
    label_gnome_download_setup="Baixando as configurações necessárias para o Gnome..."

    #Download do sistema
    label_ubuntu_download="Baixando o Ubuntu..."

    #TITULO DO MENU DE DIALOGO
    MENU_operating_system_select="Escolha o sistema operacional que será instalado: "
    MENU_language_select="Idioma a instalar: "
    MENU_environments_select="Escolha um ambientes de área de trabalho: "

#fi

if [ "$system_country" = "Brazil" ]; then
  system_country="Brasil"
fi

