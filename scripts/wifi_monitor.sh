#!/bin/bash

. /opt/fpp/scripts/common
. /opt/fpp/scripts/functions

check_wifi() {
    # Let MaybeEnableTethering handle tethering logic
    TetherEnabled=$(getSetting EnableTethering)
    if [ "x${TetherEnabled}" == "x" ]; then
        TetherEnabled=0
    fi
    
    # Only proceed if tethering isn't disabled (state 2)
    if [ "$TetherEnabled" != "2" ]; then
        # Check if we have a connection
        IPS="$(ip -o -4 addr | grep -v usb | grep -v 127.0 | grep -v 'wlan. *inet 192.168.8.1')"
        
        if [ -z "$IPS" ]; then
            # No connection, let MaybeEnableTethering handle it
            MaybeEnableTethering
        fi
        
        # If in tethering mode or no connection, scan for configured networks
        if [ -f /etc/hostapd/hostapd.conf ] || [ -z "$IPS" ]; then
            TetherInterface=$(FindTetherWIFIAdapater)
            CONFIGS=$(ls ${FPPHOME}/media/config/interface.w* 2>/dev/null)
            for f in $CONFIGS; do
                unset SSID
                . ${f}
                if [ ! -z "$SSID" ]; then
                    SCAN=$(iwlist ${TetherInterface} scan 2>/dev/null | grep "ESSID:\"${SSID}\"")
                    if [ ! -z "$SCAN" ]; then
                        echo "Found configured network ${SSID}, attempting to connect..."
                        SetupFPPNetworkConfig
                        break
                    fi
                fi
            done
        fi
    fi
}

# Main loop
while true; do
    check_wifi
    sleep 30
done