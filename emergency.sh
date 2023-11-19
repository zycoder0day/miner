#!/bin/bash

. /hive/miners/lolminer/h-manifest.conf
log=`ls -d1 /var/log/miner/custom/* | tail -1`
#save last messages about hanging cards

if [[ -f "$log" ]]; then
   tail -n 50 $log > ${log}_reboot.log
   lastmsg=`tac ${log}_reboot.log | grep -m1 -E "Unrecover" | sed 's/\x1b\[[0-9;]*m//g'`
   if [ -z "$lastmsg" ]; then
     lastmsg=`tac ${log}_reboot.log | grep -m1 -E "crashed" | sed 's/\x1b\[[0-9;]*m//g'`
   fi
   [[ -z $lastmsg ]] && lastmsg='reboot'
fi

if [[ -f "${log}_reboot.log" ]]; then
   echo -e "=== Last 50 lines of ${MINER_LOG_BASENAME}.log ===\n`tail -n 50 ${MINER_LOG_BASENAME}_reboot.log`" | /hive/bin/message danger "${MINER_NAME}: $lastmsg" payload
else
   /hive/bin/message danger "${MINER_NAME}: reboot"
fi

#need nohup or the sreboot will stop miner and this process also in it
#nohup bash -c 'sreboot' > /tmp/nohup.log 2>&1 &
sreboot

exit 0
