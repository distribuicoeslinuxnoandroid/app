#!/bin/bash
#XFCE4 config environment
source "/usr/local/bin/fixed_variables.sh"

#Get the necessary components
(
    echo 0  # Inicia em 0%
    sudo apt-get update

    echo 8
    sudo apt-get install xfce4 --no-install-recommends -y > /dev/null 2>&1

    echo 16
    sudo apt-get install xfce4-goodies --no-install-recommends -y > /dev/null 2>&1

    echo 24
    sudo apt-get install xfce4-terminal --no-install-recommends -y > /dev/null 2>&1

    echo 32  # Finaliza em 100%
    sudo apt-get install xfce4-panel-profiles -y > /dev/null 2>&1

    echo 40  # Finaliza em 100%
    sudo apt-get install dbus-x11 --no-install-recommends -y > /dev/null 2>&1

    echo 48  # Finaliza em 100%
    sudo apt-get clean

    mkdir -p ~/.vnc

echo '#!/bin/bash
export PULSE_SERVER=127.0.0.1
export LANG
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
echo $$ > /tmp/xsession.pid
dbus-launch --exit-with-session /usr/bin/startxfce4' > ~/.vnc/xstartup

    chmod +x ~/.vnc/xstartup

    echo 'export DISPLAY=":1"' >> /etc/profile

    source /etc/profile

    wget --tries=20 "${extralink}/config/environment/xfce4/start-environment.sh" > /dev/null 2>&1
	chmod +x ~/start-environment.sh

 ) | dialog --gauge "${label_install_environment_gui}" 6 40 0

vncpasswd

