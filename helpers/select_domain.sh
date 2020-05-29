#! /bin/bash

#========================================================
# Filename: choose_domain.sh
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


domains=($(cat $DOMAINLIST| cut -d: -f1))
text=$1
dialog="dialog --backtitle \"$BACKTITLE\" --no-items --radiolist \"$text\" 0 0 0"
c=0
while read -r line; 
do     
    if (( $c == 0)); then dialog+=" '$line' on"; ((c++))
    else dialog+=" '$line' off"
    fi
done < <(for item in ${domains[*]}; do echo "$item"; done)
dialog+=' 2>&1 1>&3'
exec 3>&1;
result=$(eval ${dialog});
exitcode=$?;
exec 3>&-;
if (( $exitcode == $DIALOG_OK ))
then
    echo $result > domain
    exit 0
else
    exit 1
fi