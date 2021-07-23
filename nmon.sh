#!/bin/sh
SCRIPTDIR="/path"
YESTERDAY="`date -d '-1 day' "+%y%m%d"`"
filename=`echo $HOSTNAME | awk -F. '{print $1}'`
cd $SCRIPTDIR
find  ./*.nmon -type f -mtime +30 | xargs  rm
#/usr/local/bin/nmon -f -s 20 -c 4320
/usr/local/bin/nmon -f -s 10 -c 8640
chown access:access  $SCRIPTDIR/${filename}_${YESTERDAY}_*.nmon
