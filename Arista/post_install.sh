#!/bin/bash

SCRIPT_DIR=/usr/lib/telegraf/scripts

function install_init {
    cp -f $SCRIPT_DIR/init.sh /etc/init.d/telegraf
    chmod +x /etc/init.d/telegraf
}

function install_chkconfig {
    chkconfig --add telegraf
}

function install_systemd {
   systemctl enable telegraf
   systemctl restart telegraf
}

function install_update_rcd {
   update-rc.d telegraf defaults
}

# Distribution-specific logic
if [[ -f /etc/redhat-release ]]; then
    # Redhat logic - Fedora/Centos
    if grep -Fq "release 18" /etc/redhat-release 
    then
       # Fedora18 logic
       install_systemd
    elif grep -Fq "release 14" /etc/redhat-release 
    then
       # Fedora14 logic, Assuming sysv
       install_init
       install_chkconfig
    else
       # Centos logic
       install_systemd
    fi
elif [[ -f /etc/debian_version ]]; then
    # Debian/Ubuntu logic
    which systemctl &>/dev/null
    if [[ $? -eq 0 ]]; then
       install_systemd
       systemctl restart telegraf || echo "WARNING: systemd not running."
    else
       # Assuming sysv
       install_init
       install_update_rcd
       invoke-rc.d telegraf restart
    fi
elif [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ $ID = "amzn" ]]; then
       # Amazon Linux logic
       install_init
       install_chkconfig
    fi
fi
