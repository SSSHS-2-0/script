#! /bin/bash
#========================================================
# Filename: user_management.sh
#
# Description:
#	Script for adding or removing users.
#
#========================================================

#Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Check for dialog
command -v dialog >/dev/null 2>&1 || { echo >&2 "I require dialog but it's not installed.  Aborting."; exit 1; }

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

function user_managment {
    exec 3>&1;
    result=$(dialog --backtitle "$BACKTITLE" \
        --cancel-label "Exit" \
        --title "User Managment" \
        --menu "" 0 0 0 \
        "1" "Display Users" \
        "2" "Add User" \
        "3" "Remove User" 2>&1 1>&3);
    exitcode=$?;
    exec 3>&-;
    if (( $exitcode == $DIALOG_OK ))
    then
        case $result in
        "1")
            display_user
        ;;

        "2")
            add_user
        ;;

        "3")
            rem_user
        ;;
        esac
    user_managment
    fi
}

function display_user {  
    dialog --backtitle "$BACKTITLE" --msgbox "$(cut -d: -f1 /etc/passwd)" 0 0
}

function add_user {
    #Get name
    exec 3>&1;
    result=$(dialog --backtitle "$BACKTITLE" --inputbox "Username:" 0 0 2>&1 1>&3);
    exitcode=$?;
    exec 3>&-;
    if (( $exitcode == $DIALOG_OK ))
    then
        newuser=$result
        #Check if name is already used
        if id -u $newuser &>/dev/null; 
        then
            dialog --backtitle "$BACKTITLE" --msgbox "User already exists" 0 0
        else
            while true; do
                #Let user define password
                exec 3>&1;
                result=$(dialog --nocancel --backtitle "$BACKTITLE" --cr-wrap --passwordbox "Enter Password\n(Password will not be shown on screen)" 0 0 2>&1 1>&3);
                exitcode=$?;
                exec 3>&-;
                if (( $exitcode == $DIALOG_OK ))
                then
                    #double check password
                    password=$result
                    exec 3>&1;
                    result=$(dialog --nocancel --backtitle "$BACKTITLE" --cr-wrap --passwordbox "Retype Password\n(Password will not be shown on screen)" 0 0 2>&1 1>&3);
                    exitcode=$?;
                    exec 3>&-;
                    if (( $exitcode == $DIALOG_OK ))
                    then
                        #define informations about user (gecos)
                        if [ "$password" == "$result" ]; then
                            gecos=""

                            exec 3>&1;
                            result=$(dialog --backtitle "$BACKTITLE" --no-cancel --inputbox "Full Name" 0 0 2>&1 1>&3)
                            gecos+=$result
                            gecos+=", "
                            result=$(dialog --backtitle "$BACKTITLE" --no-cancel --inputbox "Room Number" 0 0 2>&1 1>&3)
                            gecos+=$result
                            gecos+=", " 
                            result=$(dialog --backtitle "$BACKTITLE" --no-cancel --inputbox "Work Phone" 0 0 2>&1 1>&3)
                            gecos+=$result
                            gecos+=", " 
                            result=$(dialog --backtitle "$BACKTITLE" --no-cancel --inputbox "Home Phone" 0 0 2>&1 1>&3)
                            gecos+=$result
                            gecos+=", " 
                            result=$(dialog --backtitle "$BACKTITLE" --no-cancel --inputbox "Other" 0 0 2>&1 1>&3)  
                            gecos+=$result
                            exec 3>&-;
                            
                            #add user with no password
                            if adduser --disabled-password --gecos "$gecos" $newuser >/dev/null 2>&1; then
                                #set password
                                echo -e "$password\n$password\n" | passwd $newuser 2>/dev/null
                                unset password
                                unset result

                                #check if user should have sudo rights
                                $LOGGING -i "Added user $newuser"
                                exec 3>&1;
                                result=$(dialog --backtitle "$BACKTITLE" --cr-wrap --yesno "User sucessfully added\nDo you want to add sudo privileges for the user?" 0 0 2>&1 1>&3)
                                exitcode=$?;
                                exec 3>&1;
                                if (( $exitcode == $DIALOG_OK ))
                                then
                                    if usermod -aG sudo $newuser; then
                                        $LOGGING -i "Added $newuser to sudo group"
                                        dialog --backtitle "$BACKTITLE" --msgbox "Successfuly added sudo privileges for user $newuser" 0 0
                                    else
                                        $LOGGING -w "Tried to add $newuser to sudo group but failed"
                                        dialog --backtitle "$BACKTITLE" --msgbox "Failed to add sudo privileges for user $newuser" 0 0
                                    fi
                                fi
                            else 
                                dialog --backtitle "$BACKTITLE" --msgbox "Adding user failed Exitcode: $?" 0 0
                            fi
                            break
                        else
                            dialog --backtitle "$BACKTITLE" --msgbox "Passwords did not match" 0 0
                        fi
                    else
                        break
                    fi
                    
                else
                    break
                fi
            done
        fi
    fi
}

function rem_user {
    dialog='dialog --backtitle "$BACKTITLE" --no-items --radiolist "Remove User" 0 0 0'
    while read -r line; 
    do     
        dialog+=" $line off"
    done < <(cut -d: -f1 /etc/passwd)
    dialog+=' 2>&1 1>&3'
    exec 3>&1;
    result=$(eval ${dialog});
    exitcode=$?;
    exec 3>&-;
    if (( $exitcode == $DIALOG_OK ))
    then
        if [ -n "$result" ]; then
            if deluser --remove-home $result >/dev/null 2>&1; then
                $LOGGING -i "deleted user $result"
                dialog --backtitle "$BACKTITLE" --msgbox "Successfully deleted user $result" 0 0
            else
                $LOGGING -i "tried to delete user $result but failed"
                dialog --backtitle "$BACKTITLE" --msgbox "Failed to delete user $result" 0 0
            fi
        fi  
    fi
}

user_managment