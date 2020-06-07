#! /bin/bash
#========================================================
# Filename: setup.sh
#
# Description:
#	Main script for the user interface.
#
#========================================================


#Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}


#Defines global vars
export SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
#export DIALOGRC="$SCRIPT_SOURCE_DIR/dialog.conf"
export BACKTITLE="Server Hardening"
export UTILS=${SCRIPT_SOURCE_DIR}/helpers
export DOMAINLIST="$SCRIPT_SOURCE_DIR/domains.list"
export PWLIST="$SCRIPT_SOURCE_DIR/generated_passwords"

#Utilities
export REMOVE_FOLDER=${UTILS}/removeFolder.sh
export GENPW=${UTILS}/genPw.sh
export REMOVE_PACKAGE=${UTILS}/removePackage.sh
export CHECK_PACKAGE=${UTILS}/checkPackage.sh
export LOGGING=${UTILS}/logging.sh
#Vars for Helpers
export SELECT_MESSAGE=""

#Defines Local vars
prefix='$_'

#Check for packages
command -v dialog >/dev/null 2>&1 || { echo >&2 "I require dialog but it's not installed.  Aborting."; exit 1; }
$CHECK_PACKAGE "docker.io"
$CHECK_PACKAGE "docker-compose"
$CHECK_PACKAGE "openssl"

#Loading name of modules into variables
#Name = foldername
function load_modules(){
    module_count=0
    for D in *; do
    if [ -d "${D}" ]; then
        FILE="${D}/install.sh"
        if test -f "$FILE"; then
            FILE="${D}/deinstall.sh"
            if test -f "$FILE"; then
                ((module_count++))
                declare -g _$module_count=$D
            fi
        fi
    fi
    done
}

#Executing install.sh
function configure_module(){
  cd $1
  ./install.sh
  cd ..
}

#Executing deinstall.sh
function remove_module(){
  cd $1
  ./deinstall.sh
  cd ..
}

#install modules
#result contains selected items if exitcode is 0 (User pressed OK)
#exitcode is 1 if user pressed Cancel
function add_modules {

dialog="dialog --backtitle \"$BACKTITLE\" --checklist \"Select Modules to harden/install\" 0 0 0"

count=0

#Go trough each module and check if the file "installed" exists
#If not then the module can get installed
for (( c=1; c<=$module_count; c++ ))
do
    FILEVAR="_$c"
    FILE="${!FILEVAR}/installed"
    if ! test -f "$FILE"; 
    then
        requirements_fullfiled=1
        while read -r line
        do 
            FILE="$SCRIPT_SOURCE_DIR/$line/installed"
            if ! test -f "$FILE"; 
            then 
                requirements_fullfiled=0
            fi
        done< <(cat ${!FILEVAR}/requirements)
        ((count++))
        if (( requirements_fullfiled == 1 )); then dialog+=" $c \"$prefix$c\" off"; fi
    fi
done
dialog+=' 2>&1 1>&3'

if ((count == 0))
then
    dialog --backtitle "$BACKTITLE" --msgbox "There are none installeable modules" 0 0
else
    exec 3>&1;
    results=$(eval ${dialog});
    exitcode=$?;
    exec 3>&-;
    if (( $exitcode == $DIALOG_OK ))
    then
        for result in $results
        do
            var="_$result"
            configure_module "${!var}"
        done
    fi
fi
}

#remove modules
#result contains selected items if exitcode is 0 (User pressed OK)
#exitcode is 1 if user pressed Cancel
function rem_modules {

dialog="dialog --backtitle \"$BACKTITLE\" --checklist \"Select Modules to remove\" 0 0 0"
count=0
for (( c=1; c<=$module_count; c++ ))
do
    FILEVAR="_$c"
    FILE="${!FILEVAR}/installed"
    if test -f "$FILE"; 
    then 
        ((count++))
        dialog+=" $c \"$prefix$c\" off"
    fi
done
dialog+=' 2>&1 1>&3'
if ((count == 0))
then
    dialog --backtitle "$BACKTITLE" --msgbox "There are none deinstallable modules" 0 0
else
    exec 3>&1;
    results=$(eval ${dialog});
    exitcode=$?;
    exec 3>&-;

    if (( $exitcode == $DIALOG_OK ))
    then
        for result in $results
        do
            var="_$result"
            remove_module "${!var}"
        done
    fi

fi
}

function update_fw {
    #check if firwall module is installed
    if test -f "$SCRIPT_SOURCE_DIR/Firewall/installed"; then
        FW_CONF="$SCRIPT_SOURCE_DIR/Firewall/fw.conf"
        dialog --backtitle "$BACKTITLE"  --infobox "Updating Firwall rules..." 0 0
        echo "" > $FW_CONF
        for (( c=1; c<=$module_count; c++ ))
        do
            FILEVAR="_$c"
            FILE="${!FILEVAR}/installed"
            if test -f "$FILE"; 
            then 
                FILE="${!FILEVAR}/ports.conf"
                if test -f "$FILE"; then
                    cat $FILE >> $FW_CONF
                fi
            fi
        done
    
        $SCRIPT_SOURCE_DIR/Firewall/specificConfigurations.sh
    else
        dialog --backtitle "$BACKTITLE" --msgbox "Firewall is not installed" 0 0
    fi
}

function menu {
exec 3>&1;
result=$(dialog --backtitle "$BACKTITLE" \
    --cancel-label "Exit" \
    --cr-wrap \
    --title "Main Menu" \
    --menu "$(cat info.txt)" 1000 1000 1000 \
    "1" "User Managment" \
    "2" "Install Modules" \
    "3" "Remove Modules"\
    "4" "Update Docker" \
    "5" "Update Firewall" 2>&1 1>&3);
exitcode=$?;
exec 3>&-;

if (( $exitcode == $DIALOG_OK ))
then
    case $result in
    "2")
    add_modules
    ;;

    "3")
    rem_modules
    ;;

    "1")
    ./user_managment.sh
    ;;

    "4")
    dialog --prgbox "Running docker skript..." ./docker.sh 1000 1000
    ;;

    "5")
    update_fw
    ;;
    esac
    #Start Menu again
    menu
fi

}

#Start Menu
load_modules
menu

#Clear the terminal at the end
#clear
