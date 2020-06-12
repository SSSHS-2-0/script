#! /bin/bash
#========================================================
# Filename: setup.sh
#
# Description:
#	Main script for the user interface.
#
#========================================================
#   The MIT License (MIT)
#   Copyright © 2020 Berner Fachhochschule
#
#   Permission is hereby granted, free of charge, to any person obtaining a copy 
#   of this software and associated documentation files (the “Software”), to deal 
#   in the Software without restriction, including without limitation the rights to 
#   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of 
#   the Software, and to permit persons to whom the Software is furnished to do so,
#   subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in all 
#   copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
#   PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
#   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
#   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
#   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
export BACKTITLE="Server Set-Up & Security-Hardening Script 2.0"
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
command -v dialog >/dev/null 2>&1 || { apt install dialog -y; }
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
        conflict_found=0
        while read -r line
        do 
            FILE="$SCRIPT_SOURCE_DIR/$line/installed"
            if ! test -f "$FILE"; 
            then 
                requirements_fullfiled=0
            fi
        done< <(cat ${!FILEVAR}/requirements)

        while read -r line
        do 
            FILE="$SCRIPT_SOURCE_DIR/$line/installed"
            if test -f "$FILE"; 
            then 
                conflict_found=1
                break
            fi
        done< <(cat ${!FILEVAR}/conflict)

        ((count++))
        if (( requirements_fullfiled == 1 && conflict_found == 0)); then dialog+=" $c \"$prefix$c\" off"; fi
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
        dialog --backtitle "$BACKTITLE"  --infobox "Updating Firewall rules..." 0 0
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
    "4" "Update Docker" 2>&1 1>&3);
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
    esac
    #Start Menu again
    menu
fi
SCRIPT_SOURCE_DIR
}

#Start Menu
load_modules
menu
update_fw
dialog --backtitle "$BACKTITLE"  --cr-wrap --msgbox "All generated passwords are stored in $SCRIPT_SOURCE_DIR/generated_passwords.\nBe sure to copy this file to a safe place and delete it." 0 0

#Clear the terminal at the end
clear
