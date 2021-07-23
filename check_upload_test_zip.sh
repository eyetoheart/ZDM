#!/bin/sh

LANG=zh_CN.GBK
export LANG
SCRIPTDIR="/path"
BACKUPDIR="/path"

DATEFORMAT="`date -d '-0 day' "+%Y%m%d%H%M%S"`"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVERUSER="access"
APPSERVERPASS='passwd'
APPSERVER_CHECK_CWL_FILE="/path"
APPSERVER_CHECK_CWL_FLAG="/path"
APPSERVER_CHECK_FUNDS_RESULT_FILE="/path"
APPSERVER_CHECK_FUNDS_RESULT_FLAG="/path"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPASS="passwd"
REMOTE_UPLOAD_CWL_FILE="/path"
REMOTE_UPLOAD_CWL_FLAG="/path"
REMOTE_UPLOAD_FUNDS_RESULT_FILE="/path"
REMOTE_UPLOAD_FUNDS_RESULT_FLAG="/path"

##############Define Function,creat file list of remote server,and save local file######################
ftp_up_file () {

cd $SCRIPTDIR
echo "open $FTPSITE" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "passive" >> $SCRIPTDIR/ftptask.txt
echo "cd $1" >> $SCRIPTDIR/ftptask.txt
echo "mput $2" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs_ftpup.log 2>&1
rm $SCRIPTDIR/ftptask.txt

}

check_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER ls $1 > $SCRIPTDIR/flag_up.txt

}

delete_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER rm $1/$2 >> $SCRIPTDIR/logs_ftpup.log 2>&1

}

getfiletolocal () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER:$1/$2 $SCRIPTDIR/$2 >> $SCRIPTDIR/logs_ftpup.log  2>&1

}

echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-�˽ű�Ϊ��Ӧ�÷�����$APPSERVER�����ļ�,���ϴ���$FTPSITE�Ľű�,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"  >> $SCRIPTDIR/logs_ftpup.log
echo "-----------------------------��¼ϵͳ Server,���Server�������ϵ�$APPSERVER_CHECK_CWL_FLAGĿ¼���Ƿ��б�־�ļ�,���ļ��б���뱾��$SCRIPTDIR/flag_up.txt�ļ���-----------------------------------" >> $SCRIPTDIR/logs_ftpup.log
check_flag  $APPSERVER_CHECK_CWL_FLAG >> $SCRIPTDIR/logs_ftpup.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/flag_up.txt ]
then
    echo "$APPSERVER��$APPSERVER_CHECK_CWL_FLAGĿ¼�´��ڱ�־�ļ�,���ڽ�Server��$APPSERVER_CHECK_CWL_FILEĿ¼�µ���Ӧ�ļ����ص�����..." >> $SCRIPTDIR/logs_ftpup.log
    for i in  `cat $SCRIPTDIR/flag_up.txt`
    do
        echo "get data:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal $APPSERVER_CHECK_CWL_FILE  $i
        echo "��$i�ļ�ѹ����,ͨ��FTP�ϴ���$FTPSITE��������$REMOTE_UPLOAD_CWL_DIRĿ¼��..." >> $SCRIPTDIR/logs_ftpup.log
        zip ${i}.zip  $i >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_CWL_FILE  ${i}.zip
        echo "����$i�ļ�������$BACKUPDIRĿ¼��..."  >> $SCRIPTDIR/logs_ftpup.log
        tar rvf $BACKUPDIR/check_up_cwl_$DATEFORMAT.tar $i >> $SCRIPTDIR/logs_ftpup.log  2>&1
        rm -rf $i
        echo "get flag:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal $APPSERVER_CHECK_CWL_FLAG  $i
        echo "�����صı�־�ļ�$i�ϴ���$FTPSITE��������$REMOTE_UPLOAD_CWL_FLAGĿ¼��" >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_CWL_FLAG  $i
        echo "ɾ��$APPSERVER������$APPSERVERFLAGĿ¼�µı�־�ļ�..." >> $SCRIPTDIR/logs_ftpup.log
        delete_flag  $APPSERVER_CHECK_CWL_FLAG  $i
        rm -rf $i
        rm -rf ${i}.zip
    done
    rm -rf flag_up.txt
else
    rm -rf flag_up.txt
fi


echo "-----------------------------��¼ϵͳ Server,���Server�������ϵ�$APPSERVER_CHECK_FUNDS_RESULT_FLAG Ŀ¼���Ƿ��б�־�ļ�,���ļ��б���뱾��$SCRIPTDIR/flag_up.txt�ļ���-----------------------------------" >> $SCRIPTDIR/logs_ftpup.log
check_flag  $APPSERVER_CHECK_FUNDS_RESULT_FLAG >> $SCRIPTDIR/logs_ftpup.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/flag_up.txt ]
then
    echo "$APPSERVER��$APPSERVER_CHECK_FUNDS_RESULT_FLAGĿ¼�´��ڱ�־�ļ�,���ڽ�Server��$APPSERVER_CHECK_FUNDS_RESULT__FILEĿ¼�µ���Ӧ�ļ����ص�����..." >> $SCRIPTDIR/logs_ftpup.log
    for i in  `cat $SCRIPTDIR/flag_up.txt`
    do
        echo "get data:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal  $APPSERVER_CHECK_FUNDS_RESULT_FILE  $i
        echo "��$i�ļ�ѹ����,ͨ��FTP�ϴ���$FTPSITE��������$REMOTE_UPLOAD_FUNDS_RESULT_DIRĿ¼��..." >> $SCRIPTDIR/logs_ftpup.log
        zip ${i}.zip  $i >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_FUNDS_RESULT_FILE  ${i}.zip
        echo "����$i�ļ�������$BACKUPDIRĿ¼��..."  >> $SCRIPTDIR/logs_ftpup.log
        tar rvf $BACKUPDIR/check_up_funds_result_$DATEFORMAT.tar $i >> $SCRIPTDIR/logs_ftpup.log  2>&1
        rm -rf $i
        echo "get flag:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal  $APPSERVER_CHECK_FUNDS_RESULT_FLAG  $i
        echo "�����صı�־�ļ�$i�ϴ���$FTPSITE��������$REMOTE_UPLOAD_FUNDS_RESULT_FLAGĿ¼��" >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_FUNDS_RESULT_FLAG  $i
        echo "ɾ��$APPSERVER������$APPSERVERFLAGĿ¼�µı�־�ļ�..." >> $SCRIPTDIR/logs_ftpup.log
        delete_flag  $APPSERVER_CHECK_FUNDS_RESULT_FLAG  $i
        rm -rf $i
        rm -rf ${i}.zip
    done
    rm -rf flag_up.txt
else
    rm -rf flag_up.txt
fi
