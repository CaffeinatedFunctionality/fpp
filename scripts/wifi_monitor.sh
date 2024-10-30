#!/bin/bash

. /opt/fpp/scripts/common
. /opt/fpp/scripts/functions

check_wifi() {
    # Get tether interface
    TetherInterface=$(FindTetherWIFIAdapater)
    
    # Check if tethering is currently enabled
    if [ -f /etc/hostapd/hostapd.conf ]; then
        # Get configured SSID from interface file
        CONFIGS=$(ls ${FPPHOME}/media/config/interface.w*)
        for f in $CONFIGS; do
            unset SSID
            . ${f}
            if [ ! -z "$SSID" ]; then
                # Check if configured network is available
                SCAN=$(iwlist ${TetherInterface} scan 2>/dev/null | grep "ESSID:\"${SSID}\"")
                if [ ! -z "$SCAN" ]; then
                    echo "Found configured network ${SSID}, disabling tethering and connecting..."
                    
                    # Stop hostapd
                    systemctl stop hostapd
                    
                    # Reconfigure network
                    SetupFPPNetworkConfig
                    
                    # Wait for connection
                    sleep 5
                    
                    # Verify connection
                    if ! iwconfig ${TetherInterface} 2>/dev/null | grep -q "ESSID:\"${SSID}\""; then
                        echo "Failed to connect to ${SSID}, re-enabling tethering..."
                        MaybeEnableTethering
                    fi
                fi
            fi
        done
    fi
}

while true; do
    check_wifi
    sleep 30
done