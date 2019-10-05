#!/bin/bash

# VER 2.0
# AUTHOR Lulz3xploit

source /etc/ovpnbook.conf

_choice_profile()
{
	if [ $path_all_openvpn_profiles ]
	then
		if [ "$openvpn_proto" == "any" ]
		then
			openvpn_proto=""
		fi

		if [ $security ] || [ "$security" == 1 ]
		then
			security="443"
		fi	
	
		profile=$(ls -R $path_all_openvpn_profiles | grep -E "*$openvpn_proto$security*.ovpn"| sort -R | sed -n 1p 2>/dev/null)

		if [ -z $profile ]
		then
			echo "No TCP SSL profile found."
			read -p "Do you want continue without SSL connection ? [Y/n]: " choice
			
			if [ "$choice" == "" ] || [ "$choice" == "y" ] || [ "$choice" == "Y" ]
			then
				profile=$(ls -R $path_all_openvpn_profiles | grep -E "*$openvpn_proto*.ovpn" |sort -R | sed -n 1p 2>/dev/null)
			else
				exit 1
			fi
		fi

		path_openvpn_profile=$path_all_openvpn_profiles$profile

		if [ ! -e "$path_openvpn_profile" ]
		then
			path_openvpn_profile=$path_all_openvpn_profiles"/"$profile
		fi

	elif [ ! $path_openvpn_profile ]
	then
		echo "No openvpn profile in config file. Please edit /etc/ovpnbook.conf"
		read -p "Temporary path of a openvpn profile: " path_openvpn_profile
	elif [ ! -e $path_openvpn_profile ]
	then
		echo "Profile: $path_openvpn_profile not found."
		read -p "Path of a openvpn profile: " path_openvpn_profile
	fi
}


_help()
{

	echo "Usage: $0 (start|stop|restart|check)"
}

_check()
{
	info=$(curl -s https://wtfismyip.com/json > /tmp/ovpn_infoip.tmp)
	isp=$(grep 'YourFuckingISP' /tmp/ovpn_infoip.tmp | cut -d'"' -f4)
	ip=$(grep 'YourFuckingIPAddress' /tmp/ovpn_infoip.tmp | cut -d'"' -f4)
	hostname=$(grep 'YourFuckingHostname' /tmp/ovpn_infoip.tmp | cut -d'"' -f4)
	loc=$(grep 'YourFuckingLocation' /tmp/ovpn_infoip.tmp | cut -d'"' -f4)
	
	rm -f /tmp/ovpn_infoip.tmp

	if [ "$isp"  == "OVH SAS" ]
	then
		echo "You are connected."
		echo "Profile: $path_openvpn_profile"
	else
		echo "You are not connected."
	fi

	echo "Your ip is: $ip"
	echo "Your location: $loc"
	echo "Your hostname: $hostname"
}

_start()
{
password_img=$(curl -s https://www.vpnbook.com/freevpn | grep -m1 'Password' | cut -d'"' -f2)
password=$(curl -s -X POST -H 'apikey: 5a64d478-9c89-43d8-88e3-c65de9999580' -F "url=https://www.vpnbook.com/$password_img" -F language=eng -F isOverlayRequired=true -F FileType=.Auto -F IsCreateSearchablePDF=false -F isSearchablePdfHideTextLayer=true -F scale=true -F detectOrientation=false -F isTable=false https://api.ocr.space/parse/image | grep -Eo '"LineText".*,' | cut -d'"' -f4 | sed "s/'//g")

echo 'vpnbook' > $auth_file
echo "$password" >> $auth_file

sudo nohup openvpn --config $path_openvpn_profile --auth-user-pass $auth_file > $log_file 2>&1 &

sleep 1 ; ps -e | grep "openvpn" | cut -d' ' -f1 > $pid_file ; sleep 1
}

_stop()
{
	if [ -e "$pid_file" ]
	then
		kill $(cat "$pid_file")
	else
		exit 1
	fi

	rm -r $auth_file
	rm -r $log_file
	rm -r $pid_file
}

if [ $# -lt 1 ]
then
	_help
	exit 1
fi

if [ $EUID -ne 0 ]
then
	echo "$0 Was been run with root permission."
	exit 1
fi

case $1 in
	"start")
		_choice_profile
		_start
		;;
	"stop")
		_stop
		;;
	"restart")
		_stop
		_choice_profile
		_start
		;;
	"check")
		_check
		;;
	*)
		_help
		exit 1
		;;
esac

exit 0
