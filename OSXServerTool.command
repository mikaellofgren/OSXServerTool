#!/bin/sh
# OSXServerTool
# 2017-06-21 Clean up and added Destroy LDAP sererver
#

# Root or not
if [ "$(id -u)" != "0" ]; then
    echo "Sorry, you are not root. Must run as root
    try sudo -s in terminal an run this again"
    exit 1
fi

SYSTEMVERSION=$(sw_vers -productVersion)


GETHOSTNAME () {
echo "Your current hostname is:"
scutil --get HostName
}

SETHOSTNAME () {
echo "To return to menu, press Enter/Return key."
echo "What hostname do you want to use to use? Your current hostname is:"
scutil --get HostName
read -r input
if  [ "$input" = "" ]; then
echo "No input returns to Menu"
else
scutil --set HostName "$input"
echo "Your current hostname is now set to:"
scutil --get HostName
fi
}

CHECKHOSTNAME () {
osascript -e 'tell application "Terminal" to do script "sudo changeip -checkhostname"'
}
 
FLUSHDNS () {
if [ "$SYSTEMVERSION" = "10.10.*" ]; then
discoveryutil udnsflushcaches; dscacheutil -flushcache;
elif [ "$SYSTEMVERSION" = "10.9.*" ]; then
dscacheutil -flushcache; killall -HUP mDNSResponder
elif [ "$SYSTEMVERSION" = "10.8.*" ]; then
killall -HUP mDNSResponder
elif [ "$SYSTEMVERSION" = "10.7.*" ]; then
killall -HUP mDNSResponder
fi
echo "DNS flushed..."
}


SLAPCONFIGMAN () {
osascript -e 'tell application "Terminal" to do script "man slapconfig"'
}


ODSTYLE () {
echo "OD style is:"
/usr/sbin/slapconfig -getstyle
}

DIRSERVSETTINGS () {
echo "Directory server settings is:"
serveradmin settings dirserv
}

GETMASTERCONFIG () {
echo "Master config status:"
/usr/sbin/slapconfig -getmasterconfig 
}


GETREPLICACONFIG () {
echo "Replica config status:"
/usr/sbin/slapconfig -getreplicaconfig 
}

UPDATEADDRESSES () {
echo "Updates the LDAP replica interface list from the password server's list:"
/usr/sbin/slapconfig -updateaddresses 
}

PREFLIGHTREPLICA () {
echo "To return to menu, press Enter/Return key."
echo "What ipaddress has Master server:"
read -r master
echo "What username has diradmin?:"
read -r username
if  [ "$master" = "" ]; then
echo "No input returns to Menu"
elif [ "$username" = "" ]; then
echo "No input returns to Menu"
else
/usr/sbin/slapconfig -preflightreplica "$master" "$username"
fi
}

TESTSLAPDCONFIGFILE () {
/usr/libexec/slapd -Tt
}

EXPORTUSERS () {
echo "Users exported to /Users/Shared/"
open . /Users/Shared/
dsexport /Users/Shared/exportedUserRecords.out /LDAPv3/127.0.0.1 dsRecTypeStandard:Users
}

EXPORTGROUPS () {
echo "Groups exported to /Users/Shared/"
open . /Users/Shared/
dsexport /Users/Shared/exportedGroupRecords.out /LDAPv3/127.0.0.1 dsRecTypeStandard:Groups
}



UNLOADOPENLDAPSLAPD () {
echo "Openldap unloaded-Stopped"
sudo launchctl unload /System/Library/LaunchDaemons/org.openldap.slapd.plist
}

LOADOPENLDAPSLAPD () {
echo "Openldap loaded-Started"
sudo launchctl load /System/Library/LaunchDaemons/org.openldap.slapd.plist
}

DB_RECOVER () {
echo "Trying db-recover from /var/db/openldap/authdata/"
sudo db_recover -h /var/db/openldap/authdata/
}

DESTROYLDAPSERVER () {
echo "Are you sure that you want to destroy Ldapserver, type YES or NO"
read -r input
if  [ "$input" = "" ]; then
echo "No input returns to Menu"
elif [ "$input" = "NO" ]; then
echo "NO, returns to Menu"
elif [ "$input" = "YES" ]; then
echo "Destroying Ldapserver"
/usr/sbin/slapconfig -destroyldapserver
fi

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
	echo "\033[1mOpen Directory Start-Stop and Recover/Destroy. Use with caution!\033[0m"
	echo "15 - Stop-Unload Openldap"
	echo "16 - Start-Load Openldap"
	echo "17 - DB_recover Openldap"
	echo "18 - Destroy Ldapserver"
	echo "19 - Exit"
    read -r selection
    echo ""
    case $selection in
        1 ) GETHOSTNAME;;
        2 ) SETHOSTNAME;;
        3 ) CHECKHOSTNAME;;
        4 ) FLUSHDNS;;
        5 ) SLAPCONFIGMAN;;
		6 ) ODSTYLE;;
		7 ) DIRSERVSETTINGS;;
		8 ) GETMASTERCONFIG;;
		9 ) GETREPLICACONFIG;;
		10 ) PREFLIGHTREPLICA;;
		11 ) TESTSLAPDCONFIGFILE;;
        12 ) UPDATEADDRESSES;;
        13 ) EXPORTUSERS;;
        14 ) EXPORTGROUPS;;
        15 ) UNLOADOPENLDAPSLAPD;;
        16 ) LOADOPENLDAPSLAPD;;
        17 ) DB_RECOVER;;
         18 ) DESTROYLDAPSERVER;;
         19 ) exit ;;
    esac
done 

exit 0




