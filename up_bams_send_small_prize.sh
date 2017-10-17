#!/bin/sh

#############################################
## file name : up_bams_send_small_prize.sh
## creator:zhangdm
## create time:2017-10-12
## modify time:2017-10-12
## copyright (C) BeiJing IWT Technology Ltd.
#############################################
LANG=zh_CN.GBK
export LANG
SCRIPTDIR="/you/path/"
BACKUPDIR="/you/path/"

DATEFORMAT="`date -d '-0 day' "+%Y%m%d%H%M%S"`"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVERUSER="access"
APPSERVERPASS='passwd'
APPSERVERFILE="/path"
APPSERVERFLAG="/path"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPASS="passwd"
REMOTE_UPLOAD_DIR="/path"

##############Define Function,creat file list of remote server,and save local file######################
ftp_up_file () {

cd $SCRIPTDIR
echo "open $FTPSITE" > $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "verbose" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "binary" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "passive" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "cd $1" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "mput $2" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "close" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
echo "bye" >> $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt >> $SCRIPTDIR/up_bams_send_small_prize.log 2>&1
rm $SCRIPTDIR/up_bams_send_small_prize_ftptask.txt

}

check_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER ls $APPSERVERFLAG > $SCRIPTDIR/bams_send_small_prize_flag_up.txt

}

delete_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER rm $APPSERVERFLAG/$1 >> $SCRIPTDIR/up_bams_send_small_prize.log 2>&1

}

getfiletolocal () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER:$APPSERVERFILE/$1 $SCRIPTDIR/$1 >> $SCRIPTDIR/up_bams_send_small_prize.log  2>&1

}

creat_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER touch $APPSERVERUPFLAG/$1 >> $SCRIPTDIR/up_bams_send_small_prize.log 2>&1

}

echo "---------------------------------�˽ű���Ӧ�÷�����$APPSERVER�����ļ�,���ϴ���$FTPSITE�Ľű�,`date "+%Y-%m-%d_%H:%M:%S"`:up_bams_send_small_prize.sh----------------------"  >> $SCRIPTDIR/up_bams_send_small_prize.log
echo "��¼ϵͳ Server,���Server�������ϵ�$APPSERVERFLAGĿ¼���Ƿ��б�־�ļ�,���ļ��б���뱾��$SCRIPTDIR/bams_send_small_prize_flag_up.txt�ļ���" >> $SCRIPTDIR/up_bams_send_small_prize.log
check_flag >> $SCRIPTDIR/up_bams_send_small_prize.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/bams_send_small_prize_flag_up.txt ]
then
    echo "$APPSERVER��$APPSERVERFLAGĿ¼�´��ڱ�־�ļ�,���ڽ�Server��$APPSERVERFILEĿ¼�µ���Ӧ�ļ����ص�����..." >> $SCRIPTDIR/up_bams_send_small_prize.log
    for i in  `cat $SCRIPTDIR/bams_send_small_prize_flag_up.txt`
    do
        cd $SCRIPTDIR
        getfiletolocal $i
        BUSI="`echo $i | awk -F[_] '{print $2}'`"
        echo "��$i�ļ�ѹ����ͨ��FTP�ϴ���$FTPSITE��������$REMOTE_UPLOAD_DIR/$BUSIĿ¼��..." >> $SCRIPTDIR/up_bams_send_small_prize.log
        zip  ${i}.zip  $i  >> $SCRIPTDIR/up_bams_send_small_prize.log
        ftp_up_file  $REMOTE_UPLOAD_DIR/$BUSI  ${i}.zip
        echo "����$i�ļ�������$BACKUPDIRĿ¼��..."  >> $SCRIPTDIR/up_bams_send_small_prize.log
        tar rvf $BACKUPDIR/up_bams_cash_${DATEFORMAT}.tar $i >> $SCRIPTDIR/up_bams_send_small_prize.log  2>&1
        echo "ɾ��$APPSERVER������$APPSERVERFLAGĿ¼�µı�־�ļ�..." >> $SCRIPTDIR/up_bams_send_small_prize.log
        delete_flag  $i
        rm -rf $i >> $SCRIPTDIR/up_bams_send_small_prize.log  2>&1
        rm -rf ${i}.zip >> $SCRIPTDIR/up_bams_send_small_prize.log  2>&1
        
    done
    rm -rf bams_send_small_prize_flag_up.txt
else
    rm -rf bams_send_small_prize_flag_up.txt
fi
