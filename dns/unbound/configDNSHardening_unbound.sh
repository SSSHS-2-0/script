#!/bin/bash

#========================================================
# Filename: configDNSHardening.sh
#
# Description: Configure Hardening and Optimization
# SOURCE: https://calomel.org/unbound_dns.html
#
#========================================================


#========================================================
# prepareRoot
#
# prepares root trust anchor and root hints file
#

function prepareRoot {
  #update of the root trust anchor
  unbound-anchor
  #move file to correct destination
  if [ -f root.hints ]; then
    mv root.hints /var/lib/unbound/
  else
     ${LOGGING} -e "root.hints file not found, please try to download by hand: wget -O root.hints https://www.internic.net/domain/named.root"
  fi
  #change owner shipp
  chown unbound:unbound /var/lib/unbound/root.hints
}

#========================================================
# getCpu
#
# get number of CPU for optimization config
#

function getCpu {
 cat /proc/cpuinfo | grep processor | wc -l
}

#========================================================
# createConfig
#
# create hardening.conf file
#

function createConfig {
cat << EOF > /etc/unbound/unbound.conf.d/hardening.conf
   ### SOURCE: https://calomel.org/unbound_dns.html ###
server:   
   # enable to not answer id.server and hostname.bind queries.
    hide-identity: yes

   # enable to not answer version.server and version.bind queries.
    hide-version: yes

  # Read  the  root  hints from this file. Default is nothing, using built in
  # hints for the IN class. The file has the format of  zone files,  with  root
  # nameserver  names  and  addresses  only. The default may become outdated,
  # when servers change,  therefore  it is good practice to use a root-hints
  # file.  get one from https://www.internic.net/domain/named.root 
    root-hints: "/var/lib/unbound/root.hints"
	
    # Will trust glue only if it is within the servers authority.
  # Harden against out of zone rrsets, to avoid spoofing attempts. 
  # Hardening queries multiple name servers for the same data to make
  # spoofing significantly harder and does not mandate dnssec.
    harden-glue: yes

  # Require DNSSEC data for trust-anchored zones, if such data is absent, the
  # zone becomes  bogus.  Harden against receiving dnssec-stripped data. If you
  # turn it off, failing to validate dnskey data for a trustanchor will trigger
  # insecure mode for that zone (like without a trustanchor).  Default on,
  # which insists on dnssec data for trust-anchored zones.
    harden-dnssec-stripped: yes

  # Use 0x20-encoded random bits in the query to foil spoof attempts.
  # http://tools.ietf.org/html/draft-vixie-dnsext-dns0x20-00
  # While upper and lower case letters are allowed in domain names, no significance
  # is attached to the case. That is, two names with the same spelling but
  # different case are to be treated as if identical. This means calomel.org is the
  # same as CaLoMeL.Org which is the same as CALOMEL.ORG.
    use-caps-for-id: yes

  # the time to live (TTL) value lower bound, in seconds. Default 0.
  # If more than an hour could easily give trouble due to stale data.
    cache-min-ttl: 3600

  # the time to live (TTL) value cap for RRsets and messages in the
  # cache. Items are not cached for longer. In seconds.
    cache-max-ttl: 86400

  # perform prefetching of close to expired message cache entries.  If a client
  # requests the dns lookup and the TTL of the cached hostname is going to
  # expire in less than 10% of its TTL, unbound will (1st) return the ip of the
  # host to the client and (2nd) pre-fetch the dns request from the remote dns
  # server. This method has been shown to increase the amount of cached hits by
  # local clients by 10% on average.
    prefetch: yes

  # number of threads to create. 1 disables threading. This should equal the number
  # of CPU cores in the machine. Our example machine has 4 CPU cores.
    num-threads: ${numCPU}

  ## Unbound Optimization and Speed Tweaks ###

  # the number of slabs to use for cache and must be a power of 2 times the
  # number of num-threads set above. more slabs reduce lock contention, but
  # fragment memory usage.
    msg-cache-slabs: 8
    rrset-cache-slabs: 8
    infra-cache-slabs: 8
    key-cache-slabs: 8

  # Increase the memory size of the cache. Use roughly twice as much rrset cache
  # memory as you use msg cache memory. Due to malloc overhead, the total memory
  # usage is likely to rise to double (or 2.5x) the total cache memory. The test
  # box has 4gig of ram so 256meg for rrset allows a lot of room for cacheed objects.
    rrset-cache-size: 256m
    msg-cache-size: 128m

  # buffer size for UDP port 53 incoming (SO_RCVBUF socket option). This sets
  # the kernel buffer larger so that no messages are lost in spikes in the traffic.
    so-rcvbuf: 1m
	
  # Should additional section of secure message also be kept clean of unsecure
  # data. Useful to shield the users of this validator from potential bogus
  # data in the additional section. All unsigned data in the additional section
  # is removed from secure messages.
    val-clean-additional: yes
	
  # If nonzero, unwanted replies are not only reported in statistics, but also
  # a running total is kept per thread. If it reaches the threshold, a warning
  # is printed and a defensive action is taken, the cache is cleared to flush
  # potential poison out of it.  A suggested value is 10000000, the default is
  # 0 (turned off). We think 10K is a good value.
    unwanted-reply-threshold: 10000
	
  # Reduce EDNS reassembly buffer size.
  # Suggested by the unbound man page to reduce fragmentation reassembly problems
	edns-buffer-size: 1472
EOF
}

# --- MAIN ---

prepareRoot
numCPU=`getCpu`
createConfig
