#!/bin/bash
# Mudar o idioma para o Portuguê Brasileiro [pt_BR]
source "/usr/local/bin/fixed_variables.sh"
source "/usr/local/bin/l10n_pt-BR.sh"

error_code="LG002br"
show_progress_dialog "steps" "${label_system_language}" 8 \
    "apt-get update" \
    "apt-get install locales -y" \
    "apt-get install language-pack-pt-base -y" \
    "sed -i 's/^# *\(pt_BR.UTF-8\)/\1/' /etc/locale.gen" \
    "locale-gen" \
    "echo 'export LC_ALL=pt_BR.UTF-8' >> ~/.bashrc" \
    "echo 'export LANG=pt_BR.UTF-8' >> ~/.bashrc" \
    "echo 'export LANGUAGE=pt_BR.UTF-8' >> ~/.bashrc" \

exit_erro
## Exportar os comandos de configuração de idioma para ~/.bashrc
## Essa configuração necessita de reboot
#sed -i '\|export LANG|a LANG=pt_BR.UTF-8|' ~/.vnc/xstartup
