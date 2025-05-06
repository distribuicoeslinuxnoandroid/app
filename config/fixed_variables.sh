#!/bin/bash
extralink="https://raw.githubusercontent.com/andistro/app/main"

#dialog
dialog_total_time=2 ## Configurar o intervalo de atualização da barra de progresso
dialog_intervalo=1 ## Número de etapas na barra de progresso
steps=$((dialog_total_time / dialog_intervalo))
percentage=0

export USER=$(whoami)
HEIGHT=0
WIDTH=100
CHOICE_HEIGHT=5
export PORT=1

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

if [ -f "$PREFIX/bin/andistro_files/l10n_${system_icu_locale_code}.sh" ]; then
    source "$PREFIX/bin/andistro_files/l10n_${system_icu_locale_code}.sh"
elif [ -f "$PREFIX/bin/andistro_files/l10n_*.sh" ]; then
    source "$PREFIX/bin/andistro_files/l10n_*.sh"
elif [ -f "/usr/local/bin/l10n_${system_icu_locale_code}.sh" ]; then
    source "/usr/local/bin/l10n_${system_icu_locale_code}.sh"
elif [ -f "/usr/local/bin/l10n_*.sh" ]; then
    source "/usr/local/bin/l10n_*.sh"
elif [ -f "/root/l10n_${system_icu_locale_code}.sh" ]; then
    source "/root/l10n_${system_icu_locale_code}.sh"
elif [ -f "/root/l10n_*.sh" ]; then
    source "/root/l10n_*.sh"
else
    echo "Arquivo de localização não encontrado para o código: $system_icu_locale_code"
    exit 1
fi


#Formato GMT
GMT_date=$(date +"%Z":00)

#cur=`pwd`

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"

exit_erro() { # ao usar esse comando, o sistema encerra caso haja erro
  if [ $? -ne 0 ]; then
    echo "Erro na execução. Abortando instalação. Código ${error_code}"
    exit 1
  fi
}

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

# Valores padrão. Toque inserir as váriáveis antes de cada código que usar essa barra de progresso.
total_steps=10  # Número total de etapas que você quer monitorar
current_step=0

# Usar o:
# ((current_step++))
# update_progress "$current_step" "$total_steps"; sleep 0.1
# Abaixo do código dentro do {} para que haja uma etapa de progresso

show_progress_dialog() {
    local mode="$1"         # "background", "wget", "steps"
    local title="$2"        # Título da barra
    local steps_or_pid="$3" # total de etapas (modo steps/wget) ou PID (modo background)
    local command_list=("${@:4}")  # Comandos (modo steps)

    (

        echo "[DEBUG] mode=$mode, title=$title, steps_or_pid=$steps_or_pid" >&2  # VERIFICAÇÃO EXTRA

        case "$mode" in
            background)
                local percentage=0
                local pid="$steps_or_pid"

                while kill -0 "$pid" >/dev/null 2>&1; do
                    sleep 0.5
                    ((percentage+=2))
                    [ $percentage -gt 95 ] && percentage=95
                    echo "$title"
                    echo "$percentage"
                done
                echo "$title"
                echo 100
                sleep 1
                ;;

            wget)
                local total="$steps_or_pid"  # Correção 1: usa o terceiro parâmetro
                shift 3                      # Correção 2: ajuste no shift

                local count=0
                local title="$title"         # Correção 3: título correto

                while [[ "$#" -gt 0 ]]; do
                    case "$1" in
                        -O)
                            local output="$2"
                            local url="$3"
                            wget --tries=20 --progress=bar:force:noscroll -O "$output" "$url" 2>&1 | \
                            stdbuf -oL grep --line-buffered "%" | \
                            stdbuf -oL sed -u -e "s,\.,,g" | \
                            awk -v count="$count" -v total="$total" -v title="$title" '
                                {
                                    match($0, /([0-9]{1,3})%/, arr);
                                    if (arr[1] != "") {
                                        percent = int((count * 100 + arr[1]) / total);
                                        print title "\n" percent;
                                    }
                                }'
                            shift 3
                            ;;
                        -P)
                            local dest="$2"
                            shift 2
                            while [[ "$#" -gt 0 && "$1" != -* ]]; do
                                local url="$1"
                                wget --tries=20 --progress=bar:force:noscroll -P "$dest" "$url" 2>&1 | \
                                stdbuf -oL grep --line-buffered "%" | \
                                stdbuf -oL sed -u -e "s,\.,,g" | \
                                awk -v count="$count" -v total="$total" -v title="$title" '
                                    {
                                        match($0, /([0-9]{1,3})%/, arr);
                                        if (arr[1] != "") {
                                            percent = int((count * 100 + arr[1]) / total);
                                            print title "\n" percent;
                                        }
                                    }'
                                ((count++))
                                shift
                            done
                            ;;
                        *)
                            echo "Erro: argumento inesperado '$1'"
                            return 1
                            ;;
                    esac
                done

                echo "$title"
                echo 100
                ;;

            wget-labeled)
                local total="${steps_or_pid}"
                local count=0
                local current_label=""
                local url=""
                local wget_opts=()

                set -- "${command_list[@]}"
                while [ $# -gt 0 ]; do
                    current_label="$1"
                    shift
                    wget_opts=()
                    
                    while [ $# -gt 1 ]; do
                        case "$1" in
                            -*) wget_opts+=("$1"); shift ;;
                            *) break ;;
                        esac
                        if [[ "$1" != -* ]]; then
                            wget_opts+=("$1")
                            shift
                        fi
                    done

                    url="$1"
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

                echo -e "XXX\n100\nConcluído\nXXX"
                ;;

            steps)
                local total="${steps_or_pid}"
                local current=0

                for cmd in "${command_list[@]}"; do
                    eval "$cmd" > /dev/null 2>&1
                    current=$((current + 1))
                    percent=$((current * 100 / total))
                    echo "$title"
                    echo "$percent"
                done
                echo "$title"
                echo 100
                ;;

            apt-labeled)
                local total="${steps_or_pid}"
                local count=0

                shift 3
                while [ $# -gt 1 ]; do
                    local label="$1"
                    local cmd="$2"
                    shift 2

                    eval "$cmd" > /dev/null 2>&1
                    percent=$(( (count + 1) * 100 / total ))
                    echo "$label"
                    echo "$percent"
                    ((count++))
                done
                ;;
        esac
    ) | dialog --gauge "$title" 6 40 0
}