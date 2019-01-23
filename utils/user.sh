#!/bin/bash

#========================================================
# Filename: user.sh
#
# Description: Manage users on a system
# Argument: Global variable to store users $USERS
#========================================================

if [ ! -z "$1" ]; then
	service=$1
fi

users=""
file=$service/users
echo -n "" > $file

function help {
    # Display help
    echo -e "Usage:"
    echo -e "\tThis function helps you manage the users on this system and select the ones you wish to provision for the $service service."
    echo -e "\tFollowing actions are available:"
    echo -e "\t\thelp: \t\tDisplay this help"
    echo -e "\t\tdisplay: \tShow all unix users on this system"
    echo -e "\t\tadd: \t\tAdd a unix user to this system (this implies the select action)"
    echo -e "\t\tdelete: \tRemove a unix user from this system (this implies the unselect action)"
    echo -e "\t\tselect: \tAdd an existing unix user to the list of users which will be provisioned for the service $service"
    echo -e "\t\tunselect: \tRemove a user from the list of users which will be provisioned for the service $service"
    echo -e "\t\tshow: \t\tShow the list of users which will be provisioned for the service $service"
    echo -e "\t\tquit: \t\tExit this function"
    read -p " *** QUESTION *** what action do you like to choose? (display/add/delete/select/unselect/show/quit/help)  " action
	echo -en "\n"
}

function _displayUsers {
	# meta functionn for reuse
    grep -Ev "nologin|false" /etc/passwd | cut -d: -f1
}

function displayUsers {
    # show all users on a system which have a valid login shell
    ${LOGGING} -i "Displaying users for this system"
    _displayUsers
}

function showUsers {
    # show all users selected for this service
    users=$(cat $file | xargs)
    ${LOGGING} -i "Displaying selected users for service $service"
    ${LOGGING} -i "$users"
}

function selectUser {
    ${LOGGING} -i "Selecting user for service $service"
	while true; do
		echo -en "\n"
    	read -p " *** QUESTION *** please enter the desired username to be selected?  " username_selected
    	echo -en "\n"
		case $username_selected in
			"")
            	${LOGGING} -i "No input found, please specify a username"
             	;;
         	*)
                if [[ "$(id -u $username_selected)" -eq 0 && "$service" == "ssh" ]]; then
                    ${LOGGING} -i "Do not use the root user for ssh, root login is not permitted. Skipping."
                    break
                else
                    if id -u $username_selected &>/dev/null; then
                        # user exists, add it to file
                        # check if already exists in file
                        if grep -q $username_selected $file; then
                            ${LOGGING} -i "User already selected, skipping"
                        else
                            echo $username_selected >> $file
                            ${LOGGING} -i "Selected $username_selected for $service"
                            users=$(cat $file | xargs)
                        fi
				    	break
                    else
                    # user does not exist, can't select
				    ${LOGGING} -i "Can't select nonexistent user $username_selected, please specify existing user or add one"
                    break
                    fi
               fi
			;;
		esac
	done
}

function unselectUser {
    ${LOGGING} -i "Unselecting user for service $service"
	while true; do
		echo -en "\n"
    	read -p " *** QUESTION *** please enter the desired username to be removed from selection?  " username_unselected
    	echo -en "\n"
		case $username_unselected in
			"")
            	${LOGGING} -i "No input found, please specify a username"
             	;;
         	*)
                    if grep -q $username_unselected $file; then
                        # user in selection, removing user
                        echo $username_unselected >> $file
                        sed -i '/'$username_unselected'/d' $file
                        ${LOGGING} -i "Removed $username_unselected from selection for $service"
                        users=$(cat $file | xargs)
                    else
                        ${LOGGING} -i "User not in selection, skipping"

                    fi
					break
			;;
		esac
	done
}


function addUser {
    ${LOGGING} -i "Adding user for this system"
	while true; do
		echo -en "\n"
    	read -p " *** QUESTION *** please enter the desired username to be added?  " username
    	echo -en "\n"
		case $username in
			"")
            	${LOGGING} -i "No input found, please specify a username"
             	;;
         	*)
                if id -u $username &>/dev/null; then
                    # user exists, ask to add it to the list
                    while true; do
                        echo -en "\n"
                        read -p " *** QUESTION *** The user exists on the system. Do you want to give $username privileges for $service? (y/N)  " add_user
                        echo -en "\n"
                        case $add_user in
                        	[yY]*)
                        	        ${LOGGING} -i "Adding $username to the list of $service users"
                                    echo $username >> $file
                                    users=$(cat $file | xargs)
                        	        break
                        	        ;;
                        	[nN]*)
                        	        ${LOGGING} -i "No privileges for $username on the service $service"
                        	        break
                        	        ;;
                        	*)
                        	        ${LOGGING} -i "Please answer with y or n"
                        	        ;;
                    	esac
                    done
					break
                else
                   # user does not exist, create new one
                    while true; do
                        read -sp "Enter new UNIX password: " password
                        echo -en "\n"
                        read -sp "Retype new UNIX password: " password_verify
                        echo -en "\n"
                        if [ "$password" == "$password_verify" ]; then
                            break
                        else
                            echo -e "Sorry, passwords do not match\nTry again"
                        fi
                    done
				    if adduser --disabled-password $username; then
				    	${LOGGING} -i "Successfully added user $username, adding it to the list for $service"
                        echo -e "$password\n$password\n" | passwd $username 2>/dev/null
                        echo "UNIX username, password: $username, $password" >> /home/$username/passwords.txt
                        unset password
                        echo $username >> $file
                        users=$(cat $file | xargs)
				    	root_rights=n
				    	while true; do
				    		echo -en "\n"
         		    		read -p " *** QUESTION *** Do you want to add sudo privileges for the user $username? (y/N)  " root_rights
         		    		echo -en "\n"
				    		case $root_rights in
                        	    [yY]*)
                        	            ${LOGGING} -i "Adding sudo privileges for user $username"
				    					sudoPrivileges $username
                        	            break
                        	            ;;
                        	    [nN]*)
                        	            ${LOGGING} -i "No sudo privileges for user $username"
                        	            break
                        	            ;;
                        	    *)
                        	            ${LOGGING} -i "Please answer with y or n"
                        	            ;;
                    		esac
				    	done
				    	break
				    else
				    	${LOGGING} -i "Failed to add user $username"
				    fi
                fi
			;;
		esac
	done
}

function sudoPrivileges {
	sudouser=$1
	if usermod -aG sudo $sudouser; then
		${LOGGING} -i "Successfuly added sudo privileges for user $sudouser"
	else
		${LOGGING} -i "Failed to add sudo privileges for user $sudouser"
	fi
}

function deleteUser {
    ${LOGGING} -i "Removing user for this system"
	while true; do
		echo -en "\n"
    	read -p " *** QUESTION *** please enter the desired username to be deleted?  " username
    	echo -en "\n"
		case $username in
			"")
            	${LOGGING} -i "No input found, please specify a username"
             	;;
         	*)
				if deluser --remove-home $username; then
					${LOGGING} -i "Successfully deleted user $username"
					break
				else
					${LOGGING} -i "Failed to delete user $username"
				fi
			;;
		esac
	done
}

# main
# ask user for desired action
action=$1
echo " !! VERY IMPORTANT !! Do not select the root user for the ssh service, access with root to ssh is not permited! You can add sudo rights to non-root users.  !! VERY IMPORTANT !!"
help
while true; do
	case $action in
		_display*)
			# meta action without interaction for reusage
			_displayUsers
            action=
			break
			;;
        help*)
        	help
            action=
        	;;
    	display*)
        	displayUsers
            action=
        	;;
    	show*)
        	showUsers
            action=
        	;;
     	select*)
        	selectUser
            action=
        	;;
     	unselect*)
        	unselectUser
            action=
        	;;
    	add*)
        	addUser
            action=
        	;;
    	delete*)
        	deleteUser
            action=
        	;;
		quit*)
			${LOGGING} -i "Leaving user management"
            action=
			break
			;;
   		*)
        users=$(cat $file | xargs)
        noofusers=$(cat $file | wc -l)
		echo -en "\n"
        ${LOGGING} -i "Number of users selected: $noofusers"
        read -p " *** QUESTION *** what action do you like to choose? (display/add/delete/select/unselect/show/quit/help)  " action
        echo -en "\n"
	esac
done;
