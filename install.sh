#!/bin/bash

_dep(){
	read -p "Do you want install dependances ? [y/n]: " choice

	case $choice in
		"Y" | "n")
			apt install -y openvpn curl
			;;
		*)
			exit 1
			;;
	esac
}

_help(){

	echo "Usage: $0 (install|repair|remove)"
}

_remove(){
        echo "Remove ovpnbook.conf in /etc/ovpnbook.conf"
        sudo rm -f /etc/ovpnbook.conf
        echo "Remove ovpnbook in /usr/local/bin/ovpnbook"
        sudo rm -f /usr/local/bin/ovpnbook
        echo -e "\nRemove complete."

}

_install(){
	echo "Search dependances..."
	if [ -n "$(dpkg -l | grep -o "openvpn")" ] 
	then
		echo "openvpn found."
	else
		_dep
	fi

	if [ -n "$(dpkg -l | grep -o "curl")" ] 
	then
		echo "curl found."
	else
		_dep
	fi

	echo "Coping ovpnbook.conf in /etc/ovpnbook.conf"
	sudo cp ovpnbook.conf /etc/
	echo "Coping ovpnbook in /usr/local/bin/ovpnbook"
	sudo cp ovpnbook.sh /usr/local/bin/ovpnbook
	chmod 755 /usr/local/bin/ovpnbook

	echo -e "\nInstallation complete."
	echo -e "Edit the config file here: /etc/ovpnbook.conf\n"
	sudo ovpnbook
}

if [ $EUID -ne 0 ]
then
	echo "$0 Was been run with root permission."
	exit 1
fi

if [ $# -lt 1 ]
then
	_help
	exit 1
fi

case $1 in
	"install")
		_install
		;;

	"repair")
		_remove
		_install
		;;
	"remove")
		_remove
		;;
	*)
		_help
		exit 1
		;;
esac

exit 0

