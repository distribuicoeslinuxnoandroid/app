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


#Formato GMT
GMT_date=$(date +"%Z":00)

#cur=`pwd`

export NEWT_COLORS="window=,white border=black,white title=black,white textbox=black,white button=white,blue"


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
                local wget_opts=()
                local urls=()
                local expect_arg=false

                for arg in "${command_list[@]}"; do
                    if $expect_arg; then
                        wget_opts+=("$arg")
                        expect_arg=false
                    elif [[ "$arg" =~ ^- ]]; then
                        wget_opts+=("$arg")
                        [[ "$arg" == "-O" || "$arg" == "--output-document" || "$arg" == "-P" || "$arg" == "--directory-prefix" ]] && expect_arg=true
                    else
                        urls+=("$arg")
                    fi
                done

                local total="${#urls[@]}"
                local count=0

                for url in "${urls[@]}"; do
                    wget --tries=20 "${wget_opts[@]}" "$url" --progress=dot:giga 2>&1 |
                    while read -r line; do
                        if [[ $line =~ ([0-9]+)% ]]; then
                            percent=$(( (count * 100 + BASH_REMATCH[1]) / total ))
                            echo "$title"
                            echo "$percent"
                        fi
                    done
                    ((count++))
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
                local expect_arg=false

                shift 3
                while [ $# -gt 0 ]; do
                    if [[ ! "$1" =~ ^- ]]; then
                        current_label="$1"
                        shift
                        wget_opts=()
                        expect_arg=false
                        while [[ $# -gt 0 && ( "$1" =~ ^- || $expect_arg ) ]]; do
                            wget_opts+=("$1")
                            if $expect_arg; then
                                expect_arg=false
                            elif [[ "$1" == "-O" || "$1" == "--output-document" || "$1" == "-P" || "$1" == "--directory-prefix" ]]; then
                                expect_arg=true
                            fi
                            shift
                        done
                        url="$1"
                        shift

                        wget --tries=20 "${wget_opts[@]}" "$url" --progress=dot:giga 2>&1 |
                        while read -r line; do
                            if [[ $line =~ ([0-9]+)% ]]; then
                                percent=$(( (count * 100 + BASH_REMATCH[1]) / total ))
                                echo "$current_label"
                                echo "$percent"
                            fi
                        done
                        ((count++))
                    fi
                done
                echo "$current_label"
                echo 100
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