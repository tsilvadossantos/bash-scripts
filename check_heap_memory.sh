#!/bin/bash
#restart glassfish if java is using more than 85% heap (threshold specified on Xmx)
#usage: bash check_heap_memory.sh

JMAPOUT="/tmp/jmapheap.out"
SCRIPT_LOG="/var/log/glassfish_mem/check_heap_memory.log"
JPROCESS=`pgrep java`
NUMPROCESSES=`echo $JPROCESS | wc -w`
PERCENTAGETHRESHOLD="85"

#Create a folder for logs if does not exist
if [ ! -d /var/log/glassfish_mem ]; then
   mkdir /var/log/glassfish_mem
fi

# Quit if there is more than one Java Process running
if [ $NUMPROCESSES -gt 1 ]; then
  echo "`date`There are more than one Java Process running. Exiting..." >> $SCRIPT_LOG
  exit 1
fi

# Quit if there isn't any Java Process running
if [ -z $JPROCESS ]; then
  echo "`date`No Java process running" >> $SCRIPT_LOG
  exit 1
fi

# Calculate the Heap Usage based on: Eden + 1 Survivor Space + concurrent mark-sweep
/usr/bin/jmap -heap $JPROCESS > $JMAPOUT
EDENSS=`grep -A 2 "New Generation" $JMAPOUT | grep used | awk '{ print $3 }'`
CONCMS=`grep -A 2 "concurrent mark-sweep generation" $JMAPOUT | grep used | awk '{ print $3 }'`
HEAP_USED_IN_BYTES=`echo "$EDENSS+$CONCMS" | bc`

# Check the Heap Memory configuration on domain.xml - parameter Xms
TOTAL_MEMORY_IN_BYTES=$(echo "$(grep Xms /srv/mbw/config/domain.xml | sed 's/[^0-9]//g')*1024*1024" |bc -l| xargs printf "%1.0f")

# Calculate the threshold based on the Xms configuration and percentage defined on this script
MEMORY_THRESHOLD_IN_BYTES=$(echo "(($TOTAL_MEMORY_IN_BYTES*$PERCENTAGETHRESHOLD)/100)" | bc)

# Log information to have some history
MEGABYTES_USED=$( echo "(($HEAP_USED_IN_BYTES/1024)/1024)" | bc)
PORCENTAGE_USED=$( echo "scale=2; ($HEAP_USED_IN_BYTES/$TOTAL_MEMORY_IN_BYTES*100)" | bc)
echo "`date` The server now is using $PORCENTAGE_USED % of heap memory" >> $SCRIPT_LOG
echo "`date` The server now is using $MEGABYTES_USED in MB of heap memory" >> $SCRIPT_LOG

# Stop the glassfish service if the process is using more memory than defined by threshold. The process is started by other script
if [ $HEAP_USED_IN_BYTES -gt  $MEMORY_THRESHOLD_IN_BYTES ] ; then
        echo "Java process using more than $PERCENTAGETHRESHOLD % Heap Memory defined on domain.xml, please investigate restarting" >> $SCRIPT_LOG
        sleep 10 && /etc/init.d/glassfish stop
        sleep 15 && kill -9 $JPROCESS &
fi
