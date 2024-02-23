#!/bin/bash
	
# Atualizar repositório
sudo apt update

# Mudar o idioma para o Portuguê Brasileiro [pt_BR]
sudo apt-get install locales language-pack-pt language-pack-pt-base language-pack-gnome-pt language-pack-gnome-pt-base -y

## Gerar o idioma
sed -i 's/^# *\(pt_BR.UTF-8\)/\1/' /etc/locale.gen
locale-gen

## Exportar os comandos de configuração de idioma para ~/.bashrc
## Essa configuração necessita de reboot
echo 'export LC_ALL=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANG=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=pt_BR.UTF-8' >> ~/.bashrc


echo 'export LC_ALL=pt_BR.UTF-8' >> ~/.bash_profile
echo 'export LANG=pt_BR.UTF-8' >> ~/.bash_profile
echo 'export LANGUAGE=pt_BR.UTF-8' >> ~/.bash_profile