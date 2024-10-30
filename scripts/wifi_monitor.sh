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
        MaybeEnableTethering
        
        # Scan for configured networks if in tethering mode
        if [ -f /etc/hostapd/hostapd.conf ]; then
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