#!/usr/bin/sudo /bin/bash

WLAN_INTERFACE=$3
SLEEP_TIME=2
SWITCH_WAIT_TIME=5

injection_mode () {
    echo "Setting $WLAN_INTERFACE into injection mode......................"
    ifconfig $WLAN_INTERFACE down
    iw mon0 del
    echo "Adding monitor to $WLAN_INTERFACE ..............................."
    iw dev $WLAN_INTERFACE interface add mon0 type monitor
    ifconfig mon0 up
    echo "Killing the notorious wpa_supplicant............................."
    killall wpa_supplicant
    sleep $SLEEP_TIME
    echo "Killing default wireless interface, wlan0........................"
    ifconfig wlan0 down
    echo "Setting channel on mon0 to $1 $2 ................................"
    iw mon0 set channel $1 $2
    echo "Injection mode active!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

monitor_mode () {
    echo "Setting $WLAN_INTERFACE into monitor mode........................"
    # Setup monitor mode, loop until it works
    iwconfig $WLAN_INTERFACE mode monitor 2>/dev/null 1>/dev/null
    echo "Bringing $WLAN_INTERFACE up......................................"
    ifconfig $WLAN_INTERFACE up
    echo "Killing the notorious wpa_supplicant............................."
    killall wpa_supplicant
    sleep $SLEEP_TIME
    echo "Killing default wireless interface, wlan0........................"
    ifconfig wlan0 down
    echo "Setting channel to monitor on $WLAN_INTERFACE to $1 $2" 
    iw $WLAN_INTERFACE set channel $1 $2
    echo "Monitor mode active!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}


echo "Bringing down $WLAN_INTERFACE ..................................."
ifconfig $WLAN_INTERFACE down 2>/dev/null 1>/dev/null

echo "Bringing up firmware............................................."
modprobe -r iwlwifi mac80211 cfg80211
modprobe iwlwifi debug=0x40000

monitor_mode

echo "Waiting for LGTM initiation......................................"
# TODO: Run a script to call MATLAB to only parse out the text, no CSI or analysis needed
./log-to-file lgtm-monitor.dat &

# Wait for key press or special token to appear in lgtm-monitor.dat
echo "Press space to initiate LGTM from this computer.................."
begin_lgtm=0
input='a'
while [[ $input != ' ' ]] && [[ $begin_lgtm < 1 ]]
do
    read -n 1 -s -t 10 input
    # TODO: Later this token, "begin-lgtm-protocol", will also include a public key
    lgtm_data=$(cat lgtm-monitor.dat | wc -l)
    if [[ $lgtm_data > 0 ]]
    then
        # Run MATLAB script to parse data into lgtm-monitor-check.dat
        
        begin_lgtm=$(cat lgtm-monitor-check.dat | grep "begin-lgtm-protocol" | wc -l)
    fi
done

# Key pressed to initiate LGTM
if [[ $input == ' ' ]]
then
    echo "Initiating LGTM protocol....................................."
    pkill log-to-file
    # undo monitor mode settings....(which are what exactly?)
    # Setup Injection mode
    # Send "begin-lgtm-protocol", TODO: later this will include a public key
    # Switch to monitor mode
    # Wait for acknowledgement + facial recognition params, TODO: later it will be ack + recog params + public key
    # Receive ack + params
    # Sleep for 5 seconds to ensure other party has switched into monitor mode....
    # Switch to injection mode
    # Send facial recognition params
    # Run MATLAB to localize signal that sent facial recognition params
    # Run OpenCV using loaded facial recognition params
    # Display, in OpenCV, a box around where the signal originated from, corresponding to the face received
    # Prompt user to accept
    # Done!
fi

# Token received from other party to initiate LGTM
if [[ begin_lgtm > 0 ]]
then
    echo "Other party initiated LGTM protocol........................."
    # Setup Injection mode
    # Sleep for 5 seconds to ensure other party has switched into monitor mode....
    # Send acknowledgement + facial recognition params, TODO: later this will inlcude a public key
    # Setup Monitor mode
    # Await facial recognition params
    # Receive facial recognition params
    # Run MATLAB to localize signal that sent facial recognition params
    # Run OpenCV using loaded facial recognition params
    # Display, in OpenCV, a box around where the signal originated from, corresponding to the face received
    # Prompt user to accept
    # Done!
fi
