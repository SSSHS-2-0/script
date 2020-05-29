#! /bin/bash
#========================================================
# Filename: select_users.sh
#
# Description: 
#   Lets user select one or more users for a module
#
#========================================================

dialog="dialog --backtitle \"$BACKTITLE\"
        --title \"User Selection\"  
        --cr-wrap
        --buildlist \"$SELECT_MESSAGE\n\nSpacebar to add user\n^ and $ to swap between columns\" 0 0 0"
while read -r line; 
do     
    dialog+=" $line $line off"
done < <(cut -d: -f1 /etc/passwd)
dialog+=' 2>&1 1>&3'
exec 3>&1;
result=$(eval ${dialog});
exitcode=$?;
exec 3>&-;
echo "$result" > users

