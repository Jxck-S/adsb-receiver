#!/bin/bash

## PRE INSTALLATION OPERATIONS

source $RECEIVER_BASH_DIRECTORY/variables.sh
source $RECEIVER_BASH_DIRECTORY/functions.sh

clear
log_project_title
log_title_heading "Setting up the TheAirTraffic client"
log_title_message "------------------------------------------------------------------------------"
if ! whiptail --backtitle "${RECEIVER_PROJECT_TITLE}" \
              --title "TheAirTraffic Feeder Client Setup" \
              --yesno "The TheAirTraffic feeder client takes data from a local dump1090 or readsb instance and shares this with TheAirTraffic. For more information please see their website:\n\n  https://theairtraffic.com/how-to-feed\n\nContinue setup by installing the TheAirTraffic feeder client?" \
              13 78; then
    echo ""
    log_alert_heading "INSTALLATION HALTED"
    log_alert_message "Setup has been halted at the request of the user"
    echo ""
    log_title_message "------------------------------------------------------------------------------"
    log_title_heading "TheAirTraffic client setup halted"
    echo ""
    exit 1
fi


## CHECK FOR PREREQUISITE PACKAGES

log_heading "Installing packages needed to fulfill TheAirTraffic client dependencies"

check_package net-tools
check_package wget


## DOWNLOAD AND EXECUTE THE THEAIRTRAFFIC CLIENT INSTALL SCRIPT

log_heading "Begining the TheAirTraffic client installation process"

log_message "Informing the user of how the installation process will work"
whiptail --backtitle "${RECEIVER_PROJECT_TITLE}" \
         --title "TheAirTraffic Client Setup" \
         --msgbox "Scripts supplied by TheAirTraffic will be used in order to install or upgrade this system. Interaction with the script executed will be required in order to complete the installation." \
         10 78

if [[ ! -d $RECEIVER_BUILD_DIRECTORY/theairtraffic ]]; then
    log_message "Creating the TheAirTraffic build directory"
    echo ""
    mkdir -v $RECEIVER_BUILD_DIRECTORY/theairtraffic 2>&1 | log_pipe
    echo ""
fi
log_message "Entering the TheAirTraffic build directory"
cd $RECEIVER_BUILD_DIRECTORY/theairtraffic

log_message "Downloading the TheAirTraffic client installation script"
echo ""
wget -v -O $RECEIVER_BUILD_DIRECTORY/theairtraffic/install.sh https://raw.githubusercontent.com/TheAirTraffic/tat-feeder/master/install.sh 2>&1 | log_pipe

log_message "Executing the TheAirTraffic client installation script"
echo ""
sudo bash $RECEIVER_BUILD_DIRECTORY/theairtraffic/install.sh
echo ""


## CHECK THE STATUS OF THE CLIENT

log_heading "Checking if the receiver is now feeding TheAirTraffic"

feed_ip=`getent hosts feed.theairtraffic.com | awk '{ print $1; exit }'`
log_message "Checking for connections on ports 30004 and 31090 to IP address ${feed_ip}"
netstat_output=`netstat -t -n | grep -E '30004|31090'`
if [[ -n $feed_ip && $netstat_output == *"${feed_ip}:30004 ESTABLISHED"* && $netstat_output == *"${feed_ip}:31090 ESTABLISHED"* ]]; then
    log_message "This device appears to be connected to TheAirTraffic"
else
    echo ""
    log_alert_message "The receiver does not appear to be feeding TheAirTraffic at this time"
    log_alert_message "Please reboot your device and run the command 'netstat -t -n | grep -E '30004|31090'' to see if a connection has been established"
    log_alert_message "If the issue persists supply the last 20 lines given by the following commands on the TheAirTraffic Discord at https://grndcntrl.net/discord"
    log_alert_message "  'sudo journalctl -u theairtraffic-feed --no-pager'"
    log_alert_message "  'sudo journalctl -u theairtraffic-mlat --no-pager'"
fi


## POST INSTALLATION OPERATIONS

whiptail --backtitle "${RECEIVER_PROJECT_TITLE}" \
         --title "TheAirTraffic Client Setup Complete" \
         --msgbox "Setup of the TheAirTraffic client is now complete. You can check your feeder status at https://theairtraffic.com/myip." \
         12 78


## SETUP COMPLETE

log_message "Returning to ${RECEIVER_PROJECT_TITLE} root directory"
cd $RECEIVER_ROOT_DIRECTORY

echo ""
log_title_message "------------------------------------------------------------------------------"
log_title_heading "TheAirTraffic client setup is complete"
echo ""
read -p "Press enter to continue..." discard

exit 0
