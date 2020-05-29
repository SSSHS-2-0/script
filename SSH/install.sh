#!/bin/bash

#========================================================
# Filename: install.sh
#
# Description: 
#   Install script for SSH.
#
#========================================================

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

#check if openssh server is installed
if ! $CHECK_PACKAGE "openssh-server"; then
    exit 1;
fi

#Select users
SELECT_MESSAGE="Please select all users who should have SSH Keys"

$UTILS/select_users.sh
users=$(cat users)
rm users

#generate ssh keys
for user in $users
do
    while true; 
    do
        #Let user define password
        exec 3>&1;
        result=$(dialog --nocancel --backtitle "$BACKTITLE" --title "Enter Password for $user" --passwordbox "Minimum five characters\nPassword will not be shown on screen" 0 0 2>&1 1>&3);
        exitcode=$?;
        exec 3>&-;
        if (( $exitcode == $DIALOG_OK ))
        then
            #double check password
            password=$result
            exec 3>&1;
            result=$(dialog --nocancel --backtitle "$BACKTITLE" --cr-wrap --title "Retype Password for $user" --passwordbox "Password will not be shown on screen" 0 0 2>&1 1>&3);
            exitcode=$?;
            exec 3>&-;
            if (( $exitcode == $DIALOG_OK ))
            then
                if [ "$password" == "$result" ]; then
                    break
                else
                    dialog --backtitle "$BACKTITLE" --msgbox "Passwords did not match" 0 0
                fi
            fi
        fi
    done

    mkdir -p /home/$user/.ssh
    touch /home/$user/.ssh/authorized_keys

    ssh-keygen -b 4096 -C "$user" -E sha256 -N ${password} -t rsa -f /home/$user/.ssh/id_rsa
    exitcode=$?
    unset password


    if (( $exitcode == 0))
    then
        cat /home/$user/.ssh/id_rsa.pub > /home/$user/.ssh/authorized_keys
        #Cleaning
        mv /home/$user/.ssh/id_rsa /home/$user/id_rsa
        mv /home/$user/.ssh/id_rsa.pub /home/$user/id_rsa.pub
        chmod 600 /home/$user/id_rsa /home/$user/id_rsa.pub
        chown $user.$user /home/$user/id_rsa /home/$user/id_rsa.pub
        chown -R $user:$user /home/$user/
        chmod 700 /home/$user/.ssh
        chmod 644 /home/$user/.ssh/authorized_keys
        dialog --backtitle "$BACKTITLE" --msgbox "Created Keys for $user" 0 0
    else
         dialog --backtitle "$BACKTITLE" --msgbox "Key creation failed for $user" 0 0
    fi
done

#configure ssh deamon
dialog --backtitle "$BACKTITLE" --infobox "Hardening SSH Server Config" 0 0
./server_config.sh
dialog --backtitle "$BACKTITLE" --infobox "Finished hardening SSH Server Config" 0 0
#restart ssh deamon
systemctl restart sshd
exitcode=$?
if (( $exitcode == 0))
then
    touch installed
    $LOGGING -i "Installed module SSH Server"
    dialog --backtitle "$BACKTITLE" --msgbox "Finished installing module" 0 0
else
    $LOGGING -e "Installing module SSH failed"
    dialog --backtitle "$BACKTITLE" --cr-wrap --msgbox "Restarting SSH Server failed\nModule is not installed" 0 0
fi
