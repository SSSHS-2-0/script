#! /bin/bash

#========================================================
# Filename: domain_managment.sh
#
# Description: 
#   Lets user add or remove domains from a list for later use
#
#========================================================

#Check for dialog
command -v dialog >/dev/null 2>&1 || { echo >&2 "I require dialog but it's not installed.  Aborting."; exit 1; }

# Define the dialog exit status code
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

domains=($(cat $DOMAINLIST| cut -d: -f1))
emails=($(cat $DOMAINLIST| cut -d: -f2))
function domain_managment {
    exec 3>&1;
    result=$(dialog --backtitle "$BACKTITLE" \
        --cancel-label "Continue witout saving" \
        --title "Domain Managment - $modulename" \
        --menu "" 0 0 0 \
        "1" "Display Domains" \
        "2" "Add Domain" \
        "3" "Remove Domain" \
        "4" "Save changes and continue" 2>&1 1>&3);
    exitcode=$?;
    exec 3>&-;
    if (( $exitcode == $DIALOG_OK ))
    then
        case $result in
        "1")
            display_domains
        ;;

        "2")
            add_domain
        ;;

        "3")
            rem_domain
        ;;

        "4")
            echo "" > $DOMAINLIST
            for index in ${!domains[*]}
            do
                if [ ! -z "${domains[$index]}" ]; then
                    echo "${domains[$index]}:${emails[$index]}" >> $DOMAINLIST
                fi
            done
            exit
        ;;
        esac
    domain_managment
    fi
}

function display_domains { 
     dialog --backtitle "$BACKTITLE" --msgbox "$(for item in ${domains[*]}; do echo "$item"; done)" 0 0
}

function add_domain {
    #Get domain
    exec 3>&1;
    domain=$(dialog --backtitle "$BACKTITLE" --inputbox "Domain: (example.com)" 0 0 2>&1 1>&3);
    exitcode=$?;
    if (( $exitcode == $DIALOG_OK ))
    then
        email=$(dialog --backtitle "$BACKTITLE" --inputbox "Email: (admin@example.com)" 0 0 2>&1 1>&3);
        exitcode=$?;
        exec 3>&-;
        if (( $exitcode == $DIALOG_OK ))
        then
            domains+=($domain)
            emails+=($email)
        fi
    fi
}

function rem_domain {
   dialog='dialog --backtitle "$BACKTITLE" --no-items --radiolist "Remove Domain" 0 0 0'
    while read -r line; 
    do     
        dialog+=" '$line' off"
    done < <(for item in ${domains[*]}; do echo "$item"; done)
    dialog+=' 2>&1 1>&3'
    exec 3>&1;
    result=$(eval ${dialog});
    exitcode=$?;
    exec 3>&-;
    if (( $exitcode == $DIALOG_OK ))
    then
        if [ -n "$result" ]; then
            domains=("${domains[@]/$result}")
        fi
    fi
}
modulename=$1
domain_managment