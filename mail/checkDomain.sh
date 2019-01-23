#!/bin/bash

#========================================================
# Filename: checkDomain.sh
#
# Description: Let user decide which domain or subdomain he wanst to use for the mailserver
#========================================================

${LOGGING} -i "Trying to fetch domain from DNS script"

maildomain=""
while true; do
	echo -en "\n"
    read -p " *** QUESTION *** Following domain is configured in dns: $DOMAIN. Do you want use this domain or a subdomain? (domain/subdomain)  " domainchoice
    echo -en "\n"
    	case $domainchoice in
			domain)
				${LOGGING} -i "Good, we are using $DOMAIN as domain for the mailserver"
				MAILDOMAIN=$DOMAIN
				break
				;;
			subdomain)
				${LOGGING} -i "Ok, let's chose a subdomain for your mailserver"
				while true; do
     				echo -en "\n"
     				read -p " *** QUESTION *** Please enter the subdomain you like to use for your mailserver (example.$DOMAIN)  " maildomain
     				echo -en "\n"
					case $maildomain in
						"")
							${LOGGING} -i "No input found, please specify a subdomain."
						;;
						*)
							${LOGGING} -i "Validating subdomain.."
							if [[ $maildomain == *"\."* ]]; then
                                # assuming the whole subdomain including the domainpart was entered
                                maildomain_prefix=${maildomain%%.*}
                                maildomain_suffix=${maildomain#*.}
                            else
                                # assuming only the subdomain part was entered
                                maildomain_prefix=$maildomain
                                maildomain_suffix=$DOMAIN
                            fi
                            if [[ "$maildomain_suffix" == "$DOMAIN" ]]; then
							    MAILDOMAIN=$maildomain_prefix"."$maildomain_suffix
                                break
                            else
                                ${LOGGING} -i "Subdomain $maildomain, has to be a part of $DOMAIN"
                            fi
                        ;;
					esac
				done
                break
                ;;
       		*)
            	${LOGGING} -i "No input found, please specify a 'domain' or 'subdomain'"
            ;;
        esac
done;
