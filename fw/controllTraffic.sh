#!/bin/bash

#========================================================
# Filename: controllTraffic.sh
#
# Description:
#       Hardens incoming and outgoing traffic of the Ubuntu UncomplicatedFirewall.
#
# Modifications:
#       11.11.18 - init version
#
#========================================================

# --- MAIN ---
ufw default deny incoming > /dev/null 2>&1
ufw default allow outgoing > /dev/null 2>&1
${LOGGING} -i "All incoming and outgoing traffic is handeled now."
