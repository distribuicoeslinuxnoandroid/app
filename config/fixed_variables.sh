#!/bin/bash
export extralink="https://raw.githubusercontent.com/andistro/app/alpha"
export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"

exit_erro() { # ao usar esse comando, o sistema encerra caso haja erro
  if [ $? -ne 0 ]; then
    echo "Erro na execução. Abortando instalação. Código ${error_code}"
    exit 1
  fi
}

check_dependencies() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        if ! dpkg -l | grep -qw "$dep"; then
            apt install -y "$dep" || exit_erro
        fi
    done
}


#dialog
dialog_total_time=2 ## Configurar o intervalo de atualização da barra de progresso
dialog_intervalo=1 ## Número de etapas na barra de progresso
steps=$((dialog_total_time / dialog_intervalo))
percentage=0


#Formato GMT
GMT_date=$(date +"%Z":00)


# VERIFICADOR DO GETPROP ==================================================================================
# Verifica se o comando getprop existe antes de executar
if command -v getprop > /dev/null 2>&1; then
    android_version=$(getprop ro.build.version.release 2>/dev/null)         # Versão do Android
    android_architecture=$(getprop ro.product.cpu.abi 2>/dev/null)         # Arquitetura do aparelho
    device_manufacturer=$(getprop ro.product.manufacturer 2>/dev/null)     # Fabricante
    device_model=$(getprop ro.product.model 2>/dev/null)                   # Modelo
    device_model_complete=$(getprop ril.product_code 2>/dev/null)          # Código do modelo

    device_hardware=$(getprop ro.hardware.chipname 2>/dev/null)            # Chipset Processador
    system_country=$(getprop ro.csc.country_code 2>/dev/null)              # País
    system_country_iso=$(getprop ro.csc.countryiso_code 2>/dev/null)       # Abreviação do País
    system_icu_locale_code=$(getprop persist.sys.locale 2>/dev/null)       # Locale
    system_timezone=$(getprop persist.sys.timezone 2>/dev/null)            # Timezone
else
    system_icu_locale_code=$(echo $LANG | sed 's/\..*//' | sed 's/_/-/')
fi


# PACOTE DE IDIOMAS ==================================================================================
# Irá carregar os pacotes de idiomas que tiver no sistema
if [ -f "$PREFIX/bin/andistro_files/l10n_${system_icu_locale_code}.sh" ]; then
    echo "Solicitando a fonte $PREFIX/bin/andistro_files/l10n_${system_icu_locale_code}.sh"
    source "$PREFIX/bin/andistro_files/l10n_${system_icu_locale_code}.sh"
elif [ -f "/usr/local/bin/l10n_${system_icu_locale_code}.sh" ]; then
    echo "Solicitando a fonte /usr/local/bin/l10n_${system_icu_locale_code}.sh"
    source "/usr/local/bin/l10n_${system_icu_locale_code}.sh"
else
    echo "Arquivo de localização não encontrado para o código: $system_icu_locale_code"
fi

# Sistema de detecção de erros ==================================================================================

# TERMINAL Progress  ==================================================================================
# A barra de progresso aparece no terminal sem caixa de dialogo
# Função para atualizar a barra de progresso
# update_progress() precisa ser definido antes de ser usado

update_progress() {
    current_step=$1
    total_steps=$2

    percent=$((current_step * 100 / total_steps))
    bar_length=30
    filled_length=$((percent * bar_length / 100))
    empty_length=$((bar_length - filled_length))

    filled_bar=$(printf "%${filled_length}s" | tr " " "=")
    empty_bar=$(printf "%${empty_length}s" | tr " " " ")

    printf "\r[%s%s] %3d%%" "$filled_bar" "$empty_bar" "$percent"
}
#total_steps=2  # Número total de etapas que você quer monitorar
current_step=0

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# ==================================================================================================
# DIALOG ===========================================================================================
# ==================================================================================================
# //////////////////////////////////////////////////////////////////////////////////////////////////

# DIALOG menu ==================================================================================
# Para o menu de seleção no dialog
export USER=$(whoami)
HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=5
export PORT=1

# DIALOG Progress ==================================================================================
# Função para ter uma barra de progresso usando o dialog em diversas tarefas
show_progress_dialog() {
    # show_progress_dialog [type] [title] [steps/count/pid] [commands...]
    # Types supported:
    #   steps         - Multiple labeled commands
    #   apt-labeled   - apt/apt-get with labels
    #   wget          - Simple download
    #   wget-labeled  - Multiple labeled downloads
    #   pid           - Background process (long-running)
    #   extract       - Extract .zip, .tar, .tar.gz, .xz

    local mode="$1"
    shift

    case "$mode" in
        apt-labeled)
            # Ex: show_progress_dialog apt-labeled 3 \
            #    "${label_update}" 'apt update' \
            #    "${label_upgrade}" 'apt full-upgrade -y' \
            #    "${label_clean}" 'apt clean'

            local steps="$1"
            shift
            {
                local percent step=0
                while [ "$#" -gt 1 ]; do
                    local label="$1"
                    local cmd="$2"
                    echo "XXX"
                    percent=$(( step * 100 / steps ))
                    echo "$percent"
                    echo "$label"
                    echo "XXX"
                    bash -c "$cmd" &>/dev/null
                    step=$((step + 1))
                    shift 2
                done
                echo "XXX"
                echo "100"
                echo "${label_done:-Concluído}"
                echo "XXX"
            } | dialog --title "$title_progress" --gauge "$title_progress" 10 70 0
            ;;

        steps)
            local label="$1"
            local steps="$2"
            shift 2
            {
                local percent step=0
                for cmd in "$@"; do
                    echo "XXX"
                    percent=$(( step * 100 / steps ))
                    echo "$percent"
                    echo "$label"
                    echo "XXX"
                    bash -c "$cmd -y" &>/dev/null
                    step=$((step + 1))
                done
                echo "XXX"
                echo "100"
                echo "${label_done:-Concluído}"
                echo "XXX"
            } | dialog --title "$label" --gauge "$label" 10 70 0
            ;;

        pid)
            # Ex: show_progress_dialog pid "${label_configure_locale}" "dpkg-reconfigure locales"
            local label="$1"
            shift
            {
                local percent=0
                local pid="$!"
                while kill -0 "$pid" 2>/dev/null; do
                    echo "XXX"
                    echo "$percent"
                    echo "$label"
                    echo "XXX"
                    percent=$(( (percent + 1) % 100 ))
                    sleep 0.2
                done
                echo "XXX"
                echo "100"
                echo "${label_done:-Concluído}"
                echo "XXX"
            } | dialog --title "$label" --gauge "$label" 10 70 0
            ;;

        pid-silent)
            # NOVO: Especial para debootstrap (sem mostrar download/output)
            # Ex: show_progress_dialog pid-silent "${label_debian_download}" \
            #     debootstrap --arch="$archurl" "$codinome" "$folder" http://ftp.debian.org/debian

            local label="$1"
            local command="$2"
            {
                bash -c "$command" &>/dev/null &
                local pid=$!
                local percent=0
                while kill -0 "$pid" 2>/dev/null; do
                    echo "XXX"
                    echo "$percent"
                    echo "$label"
                    echo "XXX"
                    percent=$(( percent < 95 ? percent + 1 : 95 ))
                    sleep 0.3
                done
                echo "XXX"
                echo "100"
                echo "${label_done:-Concluído}"
                echo "XXX"
            } | dialog --title "$label" --gauge "$label" 10 70 0
            ;;

        
        wget)
            # Ex: show_progress_dialog wget "${label}" -O arquivo URL
            # Ex: show_progress_dialog wget "${label_download}" \
            #     -O "$HOME/arquivo.tar.xz" "${url_do_arquivo}"

            local label="$1"
            shift
            {
                wget "$@" &>/dev/null &
                local pid=$!
                local percent=0
                while kill -0 "$pid" 2>/dev/null; do
                    echo "XXX"
                    echo "$percent"
                    echo "$label"
                    echo "XXX"
                    percent=$(( percent < 95 ? percent + 1 : 95 ))
                    sleep 0.3
                done
                echo "XXX"
                echo "100"
                echo "${label_done:-Concluído}"
                echo "XXX"
            } | dialog --title "$label" --gauge "$label" 10 70 0
            ;;

        wget-labeled)
            local label="$1"
            local total="$2"
            shift 2

            {
                local count=0

                while [ $# -gt 0 ]; do
                    local current_label="$1"
                    shift
                    local wget_opts=()
                    while [[ $# -gt 1 && "$1" == -* ]]; do
                        wget_opts+=("$1")
                        shift
                        wget_opts+=("$1")
                        shift
                    done
                    local url="$1"
                    shift

                    echo -e "XXX\n$((count * 100 / total))\n${current_label}\nXXX"

                    wget --tries=20 --progress=bar:force:noscroll "${wget_opts[@]}" "$url" 2>&1 |
                    stdbuf -oL grep --line-buffered "%" |
                    stdbuf -oL sed -u -e "s,\.,,g" | awk -v count="$count" -v total="$total" -v label="$current_label" '
                        {
                            match($0, /([0-9]{1,3})%/, arr);
                            if (arr[1] != "") {
                                percent = int((count * 100 + arr[1]) / total);
                                print "XXX\n" percent "\n" label "\nXXX";
                            }
                        }'

                    ((count++))
                done

                echo -e "XXX\n100\n${label_done:-Concluído}\nXXX"
            } | dialog --title "$label" --gauge "$label" 10 70 0
            ;;



        extract)
            # Uso: show_progress_dialog extract "Extraindo arquivos..." /caminho/arquivo.ext [diretório_destino]
            local label="$1"
            local file="$2"
            local dest="$3"

            # Se destino não especificado, usar diretório atual
            [ -z "$dest" ] && dest="."

            case "$file" in
            *.tar.xz) cmd=(tar -xJf "$file" -C "$dest") ;;
            *.tar.gz|*.tgz) cmd=(tar -xzf "$file" -C "$dest") ;;
            *.tar.bz2) cmd=(tar -xjf "$file" -C "$dest") ;;
            *.tar) cmd=(tar -xf "$file" -C "$dest") ;;
            *.zip) cmd=(unzip -o "$file" -d "$dest") ;;
            *.xz) cmd=(xz -d "$file") ;;
            *.gz) cmd=(gunzip "$file") ;;
            *) 
                dialog --title "Erro" --msgbox "Formato de arquivo não suportado: $file" 10 50
                return 1
                ;;
            esac

            # Executa extração em background
            set +m
            (
            "${cmd[@]}" >/dev/null 2>&1
            ) & disown
            pid=$!

            # Barra de progresso fluida baseada em PID
            {
            i=0
            while kill -0 "$pid" 2>/dev/null; do
                echo $i
                sleep 0.2
                i=$((i + 2))
                [ $i -ge 95 ] && i=95
            done
            #wait "$pid"
            echo 100
            set -m
            } | dialog --gauge "$label" 10 70 0
            ;;

        *)
            echo "Modo desconhecido para show_progress_dialog: $mode" >&2
            return 1
            ;;
    esac
}
