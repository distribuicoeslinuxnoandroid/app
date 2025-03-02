#!/data/data/com.termux/files/usr/bin/bash
echo "O ${folder} está funcionando"
(
				echo 0  # Inicia em 0%
				sed -i 's|command+=" LANG=C.UTF-8"|command+=" LANG=pt_BR.UTF-8"|' $bin
				wget --tries=20 "${extralink}/config/locale/locale_pt-BR.sh" -P $folder/root > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 14  # Finaliza em 14%
			) | whiptail --gauge "${label_language_download}" 0 0 0

			(
				echo 15  # Inicia em 15%
				wget --tries=20 "${extralink}/config/tigervnc/pt-BR/vnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 29  # Finaliza em 29%
			) | whiptail --gauge "${label_language_download}" 0 0 0
			(
				echo 30  # Inicia em 30%
				wget --tries=20 "${extralink}/config/tigervnc/pt-BR/vncpasswd" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 44  # Finaliza em 44%
			) | whiptail --gauge "${label_language_download}" 0 0 0
			(
				echo 45  # Inicia em 45%
				wget --tries=20 "${extralink}/config/tigervnc/pt-BR/startvnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 59  # Finaliza em 59%
			) | whiptail --gauge "${label_language_download}" 0 0 0
			(
				echo 60  # Inicia em 60%
				wget --tries=20 "${extralink}/config/tigervnc/pt-BR/stopvnc" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 74  # Finaliza em 74%
			) | whiptail --gauge "${label_language_download}" 0 0 0
			(
				echo 75  # Inicia em 75%
				wget --tries=20 "${extralink}/config/tigervnc/pt-BR/startvncserver" -P $folder/usr/local/bin > /dev/null --progress=dot:giga 2>&1 | while read -r line; do
					# Extraindo a porcentagem do progresso do wget
					if [[ $line =~ ([0-9]+)% ]]; then
						percent=${BASH_REMATCH[1]}
						echo $percent  # Atualiza a barra de progresso
					fi
				done

				echo 100  # Finaliza em 100%
			) | whiptail --gauge "${label_language_download}" 0 0 0

			chmod +x $folder/root/locale_pt-BR.sh