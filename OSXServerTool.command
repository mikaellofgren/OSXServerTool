#!/bin/sh
# OSXServerTool

# Root or not
if [ "$(id -u)" != "0" ]; then
    echo "Sorry, you are not root. Must run as root
    try sudo -s in terminal an run this again"
    exit 1
fi

systemversion='sw_vers -productVersion'


function gethostname() {
echo "Your current hostname is:"
scutil --get HostName
}

function sethostname() {
echo "To return to menu, press Enter/Return key."
echo "What hostname do you want to use to use? Your current hostname is:"
scutil --get HostName
read input
if  [ "$input" = "" ]; then
echo "No input returns to Menu"
else
scutil --set HostName "$input"
echo "Your current hostname is now set to:"
scutil --get HostName
fi
}

function checkhostname() {
osascript -e 'tell application "Terminal" to do script "sudo changeip -checkhostname"'
}
 
function flushdns() {
if [[ "$systemversion" == "10.10.*" ]]; then
discoveryutil udnsflushcaches; dscacheutil -flushcache;
elif [[ "$systemversion" == "10.9.*" ]]; then
dscacheutil -flushcache; killall -HUP mDNSResponder
elif [[ "$systemversion" == "10.8.*" ]]; then
killall -HUP mDNSResponder
elif [[ "$systemversion" == "10.7.*" ]]; then
killall -HUP mDNSResponder
fi
echo "DNS flushed..."
}


function slapconfigman() {
osascript -e 'tell application "Terminal" to do script "man slapconfig"'
}


function odstyle() {
echo "OD style is:"
/usr/sbin/slapconfig -getstyle
}

function dirservSettings() {
echo "Directory server settings is:"
serveradmin settings dirserv
}

function getmasterconfig() {
echo "Master config status:"
/usr/sbin/slapconfig -getmasterconfig 
}


function getreplicaconfig() {
echo "Replica config status:"
/usr/sbin/slapconfig -getreplicaconfig 
}

function updateaddresses() {
echo "Updates the LDAP replica interface list from the password server's list:"
/usr/sbin/slapconfig -updateaddresses 
}

function preflightreplica() {
echo "To return to menu, press Enter/Return key."
echo "What ipaddress has Master server:"
read master
echo "What username has diradmin?:"
read username
if  [ "$master" = "" ]; then
echo "No input returns to Menu"
elif [ "$username" = "" ]; then
echo "No input returns to Menu"
else
/usr/sbin/slapconfig -preflightreplica "$master" "$username"
fi
}

function testslapdconfigfile() {
/usr/libexec/slapd -Tt
}

function exportUsers() {
echo "Users exported to /Users/Shared/"
open . /Users/Shared/
dsexport /Users/Shared/exportedUserRecords.out /LDAPv3/127.0.0.1 dsRecTypeStandard:Users
}

function exportGroups() {
echo "Groups exported to /Users/Shared/"
open . /Users/Shared/
dsexport /Users/Shared/exportedGroupRecords.out /LDAPv3/127.0.0.1 dsRecTypeStandard:Groups
}



function unloadOpenldapSlapd() {
echo "Openldap unloaded-Stopped"
sudo launchctl unload /System/Library/LaunchDaemons/org.openldap.slapd.plist
}

function loadOpenldapSlapd() {
echo "Openldap loaded-Started"
sudo launchctl load /System/Library/LaunchDaemons/org.openldap.slapd.plist
}

function db_recover() {
echo "Trying db-recover from /var/db/openldap/authdata/"
sudo db_recover -h /var/db/openldap/authdata/
}

selection=
until [ "$selection" = "0" ]; do
    echo ""
    echo "\033[1mOSX Servertools\033[0m"
    echo "1 - Get Hostname"
    echo "2 - Set Hostname"
    echo "3 - Changeip-checkhostname"
    echo "4 - Flushdns"
	echo "\033[1mOpen Directory Tools\033[0m"
	echo "5 - Slapconfig manpage"
    echo "6 - Get OD Style"
    echo "7 - Get OD settings"
    echo "8 - Master Config status"
    echo "9 - Replica Config status"
    echo "10 - Replica Preflight run from OD replica"
    echo "11 - Test slapdconfig file"
	echo "12 - SlapConfig Update Addresses"
	echo "\033[1mOpen Directory Export Users and Groups\033[0m"
	echo "13 - Export OD users"
	echo "14 - Export OD groups"
	echo "\033[1mOpen Directory Start-Stop and Recover. Use with caution!\033[0m"
	echo "15 - Stop-Unload Openldap"
	echo "16 - Start-load Openldap"
	echo "17 - DB_recover Openldap"
	
	
	
	echo "18 - Exit"
    read selection
    echo ""
    case $selection in
        1 ) gethostname;;
        2 ) sethostname;;
        3 ) checkhostname ;;
        4 ) flushdns ;;
        5 )  slapconfigman ;;
		6 ) odstyle ;;
		7 )  dirservSettings ;;
		8 )  getmasterconfig ;;
		9 ) getreplicaconfig  ;;
		10 ) preflightreplica ;;
		11 ) testslapdconfigfile  ;;
        12 ) updateaddresses ;;
        13 ) exportUsers ;;
        14 ) exportGroups ;;
        15 ) unloadOpenldapSlapd ;;
        16 ) loadOpenldapSlapd ;;
        17 ) db_recover ;;
         18 ) exit ;;
    esac
done 

exit 0




