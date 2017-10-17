#!/bin/sh
##########**********Define Envionment Variables**********##########
SCRIPTDIR="/path"
BACKUPDIR="/path"
CONFIGFILE="/path/config.txt"
YESTDATEFULL="`date -d '-2 day' "+%Y-%m-%d"`"
HOSTNAME="`hostname |awk -F. '{print $1}'`"

for  i  in  `cat $CONFIGFILE`
do
	DIR1="`echo $i | awk -F: '{print $1}'`"
	DIR2="`echo $i | awk -F: '{print $2}'`"
	FILEQZ="`echo $i | awk -F: '{print $3}'`"
	DIRPATH="`echo $DIR2 | sed 's/\//_/g'`"
	cd $DIR1
	cd $DIR2
	echo "tar $DIR1$DIR2 directory log file" >> $SCRIPTDIR/logs.log
	tar -cvf ${HOSTNAME}_logbackup_${DIRPATH}_${FILEQZ}_${YESTDATEFULL}.tar ${FILEQZ}${YESTDATEFULL}*.log > /dev/null 2>&1
	echo "move tar pack to $BACKUPDIR dirctory" >> $SCRIPTDIR/logs.log 2>&1
	mv ${HOSTNAME}_logbackup_${DIRPATH}_${FILEQZ}_${YESTDATEFULL}.tar $BACKUPDIR > /dev/null 2>&1
	echo "delete source log file" >> $SCRIPTDIR/logs.log
	rm -f ${FILEQZ}${YESTDATEFULL}*.log
	cd $BACKUPDIR
	tar -rvf ${HOSTNAME}_logbackup${YESTDATEFULL}.tar ${HOSTNAME}_logbackup_${DIRPATH}_${FILEQZ}_${YESTDATEFULL}.tar > /dev/null 2>&1
	rm ${HOSTNAME}_logbackup_${DIRPATH}_${FILEQZ}_${YESTDATEFULL}.tar
done

cd $BACKUPDIR
echo "compress tar pack file" >> $SCRIPTDIR/logs.log 2>&1
gzip ${HOSTNAME}_logbackup${YESTDATEFULL}.tar >> $SCRIPTDIR/logs.log 2>&1
echo "-------------------------`date +"%Y-%m-%d_%H:%M:%S"`---------------------" >> $SCRIPTDIR/logs.log
