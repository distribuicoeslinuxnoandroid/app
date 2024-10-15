#!/bin/bash
	
# Atualizar repositório
(
    echo 0  # Inicia em 0%
    
    echo "Atualizando pacotes..."
    sudo apt update > /dev/null 2>&1  # Executa o comando e oculta a saída
    echo 100  # Finaliza em 100%
) | whiptail --gauge "Procurando atgualizações..." 0 0 0

# Mudar o idioma para o Portuguê Brasileiro [pt_BR]
sudo apt-get install locales language-pack-pt language-pack-pt-base language-pack-gnome-pt language-pack-gnome-pt-base wbrazilian hunspell-pt-br -y
#sudo apt-get install firefox-locale-pt libreoffice-l10n-pt-br libreoffice-lightproof-pt-br -y

## Gerar o idioma
sed -i 's/^# *\(pt_BR.UTF-8\)/\1/' /etc/locale.gen
locale-gen

## Exportar os comandos de configuração de idioma para ~/.bashrc
## Essa configuração necessita de reboot
echo 'export LC_ALL=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANG=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=pt_BR.UTF-8' >> ~/.bashrc