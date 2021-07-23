#!/bin/sh

###################Define Envionment Variables########
SCRIPTDIR="/home/iwgoup/backup/script/ocrpicbak"
BACKUPDIR="/home/iwgoup/backup/databak/picbak"
SOURCEDIR="/opt/iwgoup/ocr/yunm/serverLottery/pic"
SERVERNAME=`echo $HOSTNAME | awk -F. '{print $1}'`

DATEDAY="`date -d '-0 day' "+%Y%m%d%H%M"`"

TEMPBAKSERV="192.168.56.21"
TEMPBAKUSER="iwgoup"
TEMPBAKPASS='abcdefg123456'
TEMPBAKPATH="/home/iwgoup/backup/databak/ocrpictemp"

export LANG=zh_CN.UTF-8

echo "+-+-+-+-+-+-+-+-+-+-start backup ocr pic,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+" >> $SCRIPTDIR/logs.log
cd $SOURCEDIR
find | sed '1d' > $SCRIPTDIR/filelist.txt
for i in `cat $SCRIPTDIR/filelist.txt`
do
    if [ ! -d $i ]
    then
        echo "start backup $i to $BACKUPDIR/$SERVERNAME_ORCPICBAK_{$DATEDAY}.ZIP" >> $SCRIPTDIR/logs.log
        zip $BACKUPDIR/${SERVERNAME}_ORCPICBAK_${DATEDAY}.ZIP  $i >> $SCRIPTDIR/logs.log  2>&1
        if [ $? -eq 0 ]
        then
            echo "backup $i Success,start delete $i from $SOURCEDIR" >> $SCRIPTDIR/logs.log
            rm -rf $i
        else
            echo "file $i backup fail!!!" >> $SCRIPTDIR/logs.log
        fi
    fi
done
rm -rf $SCRIPTDIR/filelist.txt
echo "Now start transfer ${SERVERNAME}_ORCPICBAK_${DATEDAY}.ZIP to $TEMPBAKSERV,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.log
/usr/local/bin/pscp -l $TEMPBAKUSER -pw $TEMPBAKPASS $BACKUPDIR/${SERVERNAME}_ORCPICBAK_${DATEDAY}.ZIP $TEMPBAKUSER@$TEMPBAKSERV:$TEMPBAKPATH >> $SCRIPTDIR/logs.log  2>&1
cd $BACKUPDIR
find  ./*.ZIP -type f -mtime +30 | xargs  rm
echo -e "+-+-+-+-+-+-+-+-+-+-end backup ocr pic,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+\n\n" >> $SCRIPTDIR/logs.log
