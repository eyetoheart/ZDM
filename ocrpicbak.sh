#!/bin/sh
#####################################################
## file name : ocrpicbak.sh
## creator : zhangdm
## create time:2019-04-01
## modify time:2019-04-01
## copyright (C) Innovative World Technology Co.,Ltd.
#####################################################

###################Define Envionment Variables########
SCRIPTDIR="/home/iwgroup/backup/script/ocrpicbak"
BACKUPDIR="/home/iwgroup/backup/databak/picbak"
SOURCEDIR="/opt/iwgroup/ocr/yunm/serverLottery/pic"
SERVERNAME=`echo $HOSTNAME | awk -F. '{print $1}'`

DATEDAY="`date -d '-0 day' "+%Y%m%d%H%M"`"

TEMPBAKSERV="192.168.56.21"
TEMPBAKUSER="iwgroup"
TEMPBAKPASS='abcdefg123456'
TEMPBAKPATH="/home/iwgroup/backup/databak/ocrpictemp"

export LANG=zh_CN.UTF-8

echo "+-+-+-+-+-+-+-+-+-+-start backup ocr pic,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+" >> $SCRIPTDIR/logs.log
cd $SOURCEDIR
find ./ -name "*.jpg" | xargs zip $BACKUPDIR/${SERVERNAME}_ORCPICBAK_${DATEDAY}.ZIP | awk '{print $2}' >> $SCRIPTDIR/filelist.txt

if [ $? -eq 0 ]
then
    echo "pic backup success,`date "+%Y-%m-%d_%H:%M:%S"`,start delete pic from $SOURCEDIR" >> $SCRIPTDIR/logs.log
    for i in `cat $SCRIPTDIR/filelist.txt`
    do
        echo "start delete $i from $SOURCEDIR" >> $SCRIPTDIR/logs.log
        rm -rf $i
    done
    rm -rf $SCRIPTDIR/filelist.txt

    sleep 300
    echo "Now start transfer ${SERVERNAME}_ORCPICBAK_${DATEDAY}.ZIP to $TEMPBAKSERV,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.log
    /usr/local/bin/pscp -l $TEMPBAKUSER -pw $TEMPBAKPASS $BACKUPDIR/${SERVERNAME}_ORCPICBAK_${DATEDAY}.ZIP $TEMPBAKUSER@$TEMPBAKSERV:$TEMPBAKPATH >> $SCRIPTDIR/logs.log  2>&1
    echo "delete $BACKUPDIR files 30 days ago..." >> $SCRIPTDIR/logs.log
    cd $BACKUPDIR
    find  ./*.ZIP -type f -mtime +30 | xargs  rm
fi
echo -e "+-+-+-+-+-+-+-+-+-+-end backup ocr pic,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+\n\n" >> $SCRIPTDIR/logs.log
