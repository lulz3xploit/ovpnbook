# ovpnbook

OvpnBook
=
ovpnbook is a bash script that is used as a service and allows you to automatically connect to an openvpn [vpnbook](https://www.vpnbook.com) profile. It has an installation and configuration file

Installation
=
    git clone https://github.com/Lulz3xploit/ovpnbook
    cd ovonbook
    chmod u+x install.sh
    ./install.sh install
    
Usage
=
- start vpn
        sudo ovpnbook start
- restart vpn
        sudo ovpnbook restart
- stop vpn
        sudo ovpnbook stop
- check connection (get ip and other...)
        sudo ovpnbook check

Config for set profile openvpn
=
- Edit config file.
    sudo nano /etc/ovpnbook.conf
    ...
    # Path of the openvpn profile to use.
    path_openvpn_profile="PATH_OF_YOUR_OPENVPN_PROFILE"
