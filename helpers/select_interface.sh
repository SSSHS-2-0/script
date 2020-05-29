#! /bin/bash

#========================================================
# Filename: select_interface.sh
#
# Description: 
#   Lets user select a network interface
#
#========================================================
select_text=$1
# Define the dialog exit status code
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

interfaces=($(ip -o link show  | grep -v lo |cut -d: -f2 | tr -d ' '))

dialog="dialog --backtitle \"$BACKTITLE\" --no-items --radiolist \"$select_text\" 0 0 0"
c=0
while read -r line; 
do
    if (( $c == 0)); then dialog+=" '$line' on"; ((c++))
    else dialog+=" '$line' off"
    fi
done < <(for item in ${interfaces[*]}; do echo "$item"; done)
dialog+=' 2>&1 1>&3'

exec 3>&1;
result=$(eval ${dialog});
exitcode=$?;
exec 3>&-;

if (( $exitcode == $DIALOG_OK ))
then
    if [ ! -z "$result" ]; then
        echo $result > selected_interface
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi