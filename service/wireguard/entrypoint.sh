#!/bin/bash
set -e

if [ "$1" = "run" ]; then
    modprobe wireguard
    
    config=$(ls /etc/wireguard/*.conf | head -1)
    if ip a | grep -q $(basename $config | cut -f 1 -d '.'); then
        echo "Stopping existing interface"
        wg-quick down $config
    fi

    echo "Starting wireguard using $config"
    wg-quick up $config
    echo "Running config:"
    wg

    shutdown() {
        echo "Stopping wireguard"
        wg-quick down $config
        rmmod wireguard
        exit 0
    }
    trap shutdown SIGINT SIGTERM SIGQUIT

    sleep infinity &
    wait

else
    exec $@
fi
