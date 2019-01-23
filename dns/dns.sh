#!/bin/bash

#========================================================
# Filename: dns.sh
#
# Description: Main Script to install & configure DNS Server
#
#========================================================


#========================================================
# initial_unbound
#
# installs initially unbound for localhost only usage
#

function initial_unbound {
    echo "*NOTE* We install two DNS Server, one for internal DNS requests (for this server and/or home clients) and one authoritative DNS Server for your domain"
	echo "*PART 0: We install the basic configuration for unbound - we come back to it later"
	localhost_only=1
    ${DNS}/dns_unbound.sh $localhost_only
}
#========================================================
# domain_info
#
# informs the user about domains
#
function domain_info {
    echo "*PART 1: We start with the authoritative Name Server: NSD"
	echo ""
	echo "!!CAUTION!! you need your own domain - IF NOT the server won't be functional"
	echo "DO NOT use a domain which does not belong to you, it may be illegal"
	echo "*NOTE* If you want to test it only, you can get a free domain like .tk or .ga - just search in your favorite web search engine (duckduckgo, google etc..)"
	echo ""
	read -p "Press enter to continue"
}
#========================================================
# get_domain_name
#
# get's domain name from user
#
function get_domain_name {
	while true; do
			echo ""
			read -p " *** QUESTION *** do you have your own domain? (y/n/abort)  "  domain_y_n
					case $domain_y_n in
					[yY]*)
							${LOGGING} -i ""
							domain_y_n=1
							break
							;;
					[nN]*)
							echo "You need your own domain, please register one (it takes like 5 min)"
							echo "we cannot continue without it!"
							;;
					abort)
							${LOGGING} -i "Abort....."
							exit 0
							;;

					 *)
							${LOGGING} -i "Please answer with y or n or abort"
							;;
		esac
	done

	while true; do
					echo ""
					read -p " *** QUESTION *** please enter your domain:   "  domain_name
					echo ""
			read -p " *** QUESTION *** is $domain_name correct? (y/n/abort)  " domain_ok
			case $domain_ok in

					[yY]*)
							${LOGGING} -i "We will configure the authoritative DNS Server with the domain: $domain_name"
                           				echo ${domain_name} > ${DNS}/domainname
							break
							;;
					[nN]*)
							echo "Please enter your domain name"
							;;
					abort)
							${LOGGING} -i "Abort....."
							exit 0
							;;
					 *)
							${LOGGING} -i "Please answer with y or n or abort"
							;;

			  esac
	done
}
#========================================================
# get_check_ipv4
#
# gets ipv4 from user
#
function get_check_ipv4 {
	ipv4=`${DNS}/../utils/getIpv4.sh`
	if [ `${DNS}/../utils/getAllIpv4.sh | wc -l` -gt 1 ] ; then
	while true; do
					echo ""
			read -p " *** QUESTION *** is this $ipv4 your external IP address ? (y (default)/n/abort)  " y_n_ip
					case $y_n_ip in

					[yY]*)
							${LOGGING} -i "We will configure the authoritative DNS Server with this: $ipv4"
                            				echo ${ipv4} > ${DNS}/domainip
							break
							;;
					[nN]*)
							ipv4=`${DNS}/../utils/chooseIp.sh 4`
                          				echo ${ipv4} > ${DNS}/domainip
							echo "You have chosen $ip4"
							;;
					abort)
							${LOGGING} -i "Abort....."
							exit 0
							;;
					 *)
                                                        ${LOGGING} -i "We will configure the authoritative DNS Server with this: $ipv4"
                                                        echo ${ipv4} > ${DNS}/domainip
                                                        break
                                                        ;;
			  esac
	done
	fi
        DOMAINIP=$ipv4
	revIpv4=`${DNS}/../utils/revIpv4.sh ${ipv4}`
}
#========================================================
# get_check_ipv6
#
# gets ipv6 from user (if available)
#
function get_check_ipv6 {
	ipv6=`${DNS}/../utils/getIpv6.sh`
	if [ `${DNS}/../utils/getAllIpv6.sh | wc -l` -gt 1 ] ; then
	while true; do
					echo ""
                        		read -p " *** QUESTION *** is this $ipv6 your external IP address ? (y (default)/n/abort)  " y_n_ip
					case $y_n_ip in

					[yY]*)
							${LOGGING} -i "We will configure the authoritative DNS Server with this: $ipv6"
							break
							;;
					[nN]*)
							ipv6=`${DNS}/../utils/chooseIp.sh 6`
							echo "You have chosen $ip6"
							;;
					abort)
							${LOGGING} -i "Abort....."
							exit 0
							;;
					 *)
                                                        ${LOGGING} -i "We will configure the authoritative DNS Server with this: $ipv6"
                                                        break
                                                        ;;
			  esac
	done
	fi
}
#========================================================
# install_nsd
#
# installs NSD with the information provided by user
#
function install_nsd {
    ${LOGGING} -i "Installing utilites for ip calculation"
    ${CHECK_PACKAGE} sipcalc
	get_check_ipv4
	get_check_ipv6
	${DNS}/dns_nsd.sh $domain_name $ipv4 $revIpv4 $ipv6
}
#========================================================
# user_info_domain
#
# informs user about domain configurations
#
function user_info_domain {
    echo ""
	echo "PART 2: You have a full functional authoritative Name Server BUT your domain hoster does not know it!"
	echo " !! VERY IMPORTANT !! GO to your domain hoster, change the name server for your domain to :"
	echo "                ns1.$domain_name with IP: $ipv4 "
        echo "                ns2.$domain_name with IP: $ipv4 "
        echo " !! VERY IMPORTANT !! DO the same for the Glue Records, with the same name server and IP's"
	echo "NOTE: It may take some time to change it - if you have difficulties with this part use your favorite web search engine"
	echo ""
	read -p "If you are done, press enter to continue"
	echo ""
}
#========================================================
# reconfig_unbound
#
# givs the user possiblity to use the unbound DNS in his internal network
#
function reconfig_unbound {
	if [ `${DNS}/../utils/getAllIpv4.sh | wc -l` -gt 1 ] ; then
		read -p "PART 3: *** QUESTION *** Do you rent this server or is it in your internal network area? If you don't know what it means just press enter. (intern / <enter> (default)) " intern
		 if [[ ${intern} == "intern" ]] ; then
				while true; do
					echo ""
					read -p " *** QUESTION *** do you want to use this DNS in your internal network area (y/n)  " internal_clients
					echo ""
					case $internal_clients in
							[yY]*)
									local_ipv4=`${DNS}/../utils/getAllIpv4.sh | grep -v $ipv4`

									if [ `${DNS}/../utils/getAllIpv4.sh | wc -l` -gt 2 ] ; then
										local_ipv4=`${DNS}/../utils/chooseIp.sh 4 $ipv4`
										echo "You have chosen $local_ipv4"
									fi

									local_ipv6=`${DNS}/../utils/getAllIpv6.sh | grep -v $ipv6`

									if [ `${DNS}/../utils/getAllIpv6.sh | wc -l` -gt 2 ] ; then
										local_ipv6=`${DNS}/../utils/chooseIp.sh 6 $ipv6`
										echo "You have chosen $local_ipv6"
									fi

									localhost_only=0
									${DNS}/dns_unbound.sh $localhost_only  $local_ipv4 $local_ipv6
									break
									;;
							[nN]*)
									${LOGGING} -i "DNS will not be reacheble in your internal network"
									break
									;;
							*)
									${LOGGING} -i "Please answer with y or n"
									;;
					esac
			done
		 fi
	else
		echo "PART 3: No more IP's left to configure..."
	fi
			${LOGGING} -i "Test local DNS"
			${DNS}/unbound/testDNS_unbound.sh
}

# --- MAIN ---

${LOGGING} -i "Starting DNS Configurations."

initial_unbound
domain_info
get_domain_name
install_nsd
user_info_domain
reconfig_unbound
echo ""
echo "Successfully installed NSD and Unbound "
echo ""
