#! /bin/bash

#========================================================
# Filename: dialog_chooseIP.sh
#
# Description: 
#   Lets user select an ip address
#
#========================================================

#Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

function chooseIp {
    
    dialog='dialog --backtitle "$BACKTITLE" --no-items --radiolist "Select IPv$version" 0 0 0'
    c=0
    if [ -z "$ipUsed" ]
    then 
       com="./../helpers/getAllIpv$version.sh"
    else
        com="./../helpers/getAllIpv${version}.sh | grep -v ${ipUsed}"
    fi

    while read -r line; 
    do  
        if (( $c == 0)); then
            dialog+=" $line on"
            ((c++))
        else
            dialog+=" $line off"
        fi
    done < <(eval $com)
    dialog+=' 2>&1 1>&3'
    exec 3>&1;
    result=$(eval ${dialog});
    exitcode=$?;
    exec 3>&-;
    if (( $exitcode == $DIALOG_OK ))
    then
        echo $result
    else
        echo "canceled"		
	fi
}

version=$1
ipUsed=$2

chooseIp