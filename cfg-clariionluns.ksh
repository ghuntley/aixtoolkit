#!/bin/ksh
#set -xv
######################################################################
#
# Script Name    : cfgluns.ksh
#
# Purpose        : Used to provision new a new LUN(s) to a VIO Server
# Note           : The "reserve_lock" attribute is updated to "no"
#                : which is a requirement for Dual VIO servers.
# Called by      : system administrator (adhoc)
# Author         : Geoffrey Huntley <ghuntley@ghuntley.com>
# Date           : 07/02/2007
######################################################################
#
echo 'Configuring EMC LUN(s) to the Virtual I/O server.'
echo 'Please review the log /tmp/cfgluns.log for more info.'
echo
exec 1>/tmp/cfgluns.log 2>&1
echo Before:
lspv 1> /tmp/cfgluns.before.$$
cat /tmp/cfgluns.before.$$
echo
cfgmgr -v
/usr/lpp/EMC/CLARiiON/bin/emc_cfgmgr
powermt config
for PV in `lspv | egrep -v "rootvg" | awk {'print $1'}`; do
echo Changing reserve_lock=no
chdev -l $PV -a reserve_lock=no -P
chdev -l $PV -a reserve_lock=no 1>/dev/null
echo Changing max_transfer=0x40000
chdev -l $PV -a max_transfer="0x40000" -P
chdev -l $PV -a max_transfer="0x40000" 1>/dev/null
done
echo
echo After:
lspv 1> /tmp/cfgluns.after.$$
cat /tmp/cfgluns.after.$$
exec 1>/dev/console 2>&1
echo If new devices were found they are displayed below:
diff /tmp/cfgluns.before.$$ /tmp/cfgluns.after.$$
rm /tmp/cfgluns.before.$$ /tmp/cfgluns.after.$$
