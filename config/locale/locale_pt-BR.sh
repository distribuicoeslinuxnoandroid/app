#!/bin/bash
# Mudar o idioma para o Portuguê Brasileiro [pt_BR]

# Ajuste das cores da GUI
extralink="https://raw.githubusercontent.com/distribuicoeslinuxnoandroid/app/main"

if [ -f "fixed_variables.sh" ]; then
    source fixed_variables.sh
    else
        (
            echo 0  # Inicia em 0%
            wget --tries=20 "${extralink}/config/fixed_variables.sh" --progress=dot:giga 2>&1 | while read -r line; do
            # Extraindo a porcentagem do progresso do wget
                if [[ $line =~ ([0-9]+)% ]]; then
                    percent=${BASH_REMATCH[1]}
                    echo $percent  # Atualiza a barra de progresso
                fi
            done
            echo 50  # Finaliza em 50%
        ) | dialog --gauge "${label_progress}" 6 40 0

        chmod +x fixed_variables.sh
        source fixed_variables.sh
fi

if [ -f "l10n_pt-BR.sh" ]; then
    source l10n_pt-BR.sh
    else
        (
            echo 51  # Inicia em 51%
            wget --tries=20 "${extralink}/config/locale/l10n_pt-BR.sh" --progress=dot:giga 2>&1 | while read -r line; do
            # Extraindo a porcentagem do progresso do wget
                if [[ $line =~ ([0-9]+)% ]]; then
                    percent=${BASH_REMATCH[1]}
                    echo $percent  # Atualiza a barra de progresso
                fi
            done
            echo 100  # Finaliza em 100%
        ) | dialog --gauge "${label_progress}" 6 40 0
        chmod +x l10n_pt-BR.sh
        source l10n_pt-BR.sh
fi

export NEWT_COLORS='window=,white border=black,white title=black,white textbox=black,white button=white,blue'

(
    echo 0
    echo ""
    
    echo 5 
    echo "Atualizando pacotes..."
    sudo apt-get update > /dev/null 2>&1
    
    echo 16
    echo "Instalando pacotes de idioma..."
    sudo apt-get install locales -y > /dev/null 2>&1
    
    echo 32
    sudo apt-get install language-pack-pt -y > /dev/null 2>&1
    
    echo 48
    sudo apt-get install language-pack-pt-base -y > /dev/null 2>&1
    
    echo 64
    #sudo apt-get install language-pack-gnome-pt -y > /dev/null 2>&1
    
    echo 80
    echo "Gerando o idioma..."
    sed -i 's/^# *\(pt_BR.UTF-8\)/\1/' /etc/locale.gen
    locale-gen > /dev/null 2>&1
    echo 100 
    
 ) | dialog --gauge "${label_system_language}" 6 40 0


## Exportar os comandos de configuração de idioma para ~/.bashrc
## Essa configuração necessita de reboot
echo 'export LC_ALL=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANG=pt_BR.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=pt_BR.UTF-8' >> ~/.bashrc

#sed -i '\|export LANG|a LANG=pt_BR.UTF-8|' ~/.vnc/xstartup
