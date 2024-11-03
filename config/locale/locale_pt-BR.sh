#!/bin/bash

# Mudar o idioma para o Portuguê Brasileiro [pt_BR]
#echo "Instalar os pacotes de idioma"
#sudo apt-get install locales language-pack-pt language-pack-pt-base language-pack-gnome-pt -y
# sudo apt-get install language-pack-gnome-pt-base wbrazilian hunspell-pt-br -y
#sudo apt-get install firefox-locale-pt libreoffice-l10n-pt-br libreoffice-lightproof-pt-br -y

## Gerar o idioma
#sed -i 's/^# *\(pt_BR.UTF-8\)/\1/' /etc/locale.gen
#locale-gen


# Ajuste das cores da GUI
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

if [ -f "fixed_variables.sh" ]; then
	chmod +x fixed_variables.sh
	bash fixed_variables.sh
	else
		wget --tries=20 "${extralink}/config/fixed_variables.sh" > /dev/null 2>&1 &
		chmod +x fixed_variables.sh
		bash fixed_variables.sh
fi

if [ -f "l10n_pt-BR.sh" ]; then # verifica se existe o arquivo
    chmod +x l10n_pt-BR.sh
    bash l10n_pt-BR.sh
    else
        wget --tries=20 "${extralink}/config/locale/l10n_pt-BR.sh" > /dev/null 2>&1 &
        chmod +x l10n_pt-BR.sh
        bash l10n_pt-BR.sh
fi

export NEWT_COLORS='window=,white border=black,white title=black,white textbox=black,white button=white,blue'

(
    echo 0  # Inicia em 0%

    echo "Atualizando pacotes..."
    sudo apt-get update > /dev/null 2>&1
    echo 16  # Atualiza para 25% após o update

    echo "Instalando pacotes de idioma..."
    sudo apt-get install locales -y > /dev/null 2>&1
    echo 32
    
    sudo apt-get install language-pack-pt -y > /dev/null 2>&1
    echo 48
    
    sudo apt-get install language-pack-pt-base -y > /dev/null 2>&1
    echo 64
    
    sudo apt-get install language-pack-gnome-pt -y > /dev/null 2>&1
    echo 80  # Atualiza para 75% após a instalação dos pacotes

    echo "Gerando o idioma..."
    sed -i 's/^# *\(pt_BR.UTF-8\)/\1/' /etc/locale.gen
    locale-gen > /dev/null 2>&1
    echo 100  # Finaliza em 100%
    
 ) | whiptail --gauge "${label_system_language}" 0 0 0


## Exportar os comandos de configuração de idioma para ~/.bashrc
## Essa configuração necessita de reboot
echo 'export LC_ALL=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANG=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=pt_BR.UTF-8' >> ~/.bashrc