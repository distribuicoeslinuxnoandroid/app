#!/bin/bash
#LXDE config environment
source "/usr/local/bin/fixed_variables.sh"

packages=(
    "sudo apt-get install lxde-core --no-install-recommends -y"
    "sudo apt-get install lxterminal --no-install-recommends -y"
    "sudo apt-get install lxappearance --no-install-recommends -y"
    "sudo apt-get install exo-utils --no-install-recommends -y"
    "sudo apt-get install tigervnc-standalone-server --no-install-recommends -y"
    "sudo apt-get install tigervnc-common --no-install-recommends -y"
    "sudo apt-get install tigervnc-tools --no-install-recommends -y"
    "sudo apt-get install dbus-x11 --no-install-recommends -y"
	"sudo apt install python3-gi -y"
	"sudo apt install python3 -y"
	"echo -e '#!/bin/bash\n[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources\nexport PULSE_SERVER=127.0.0.1\nexport LANG\n[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup\n[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources\necho $$ > /tmp/xsession.pid\ndbus-launch --exit-with-session startlxde' > ~/.vnc/xstartup"
	"chmod +x ~/.vnc/xstartup"
	"echo 'export DISPLAY=":1"' >> /etc/profile"
	"source /etc/profile"
	"wget --tries=20 '${extralink}/config/environment/lxde/start-environment.sh'"
	"chmod +x ~/start-environment.sh"
)
show_progress_dialog "apt-labeled" "${label_install_environment_gui}" 8 "${packages[@]}"

vncpasswd
