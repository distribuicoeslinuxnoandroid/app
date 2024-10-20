#!/bin/bash
	
# Atualizar repositório

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