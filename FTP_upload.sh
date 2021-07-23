#!/bin/sh

LANG=zh_CN.UTF-8
export LANG
SCRIPTDIR="/path"
DATADIR="/path"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPORT="port number"
FTPPASS="passwd"
FTPUPLOADDIR="/path"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVERNAME="access"
APPSERVERPASS='passwd'
APPSERVERDATA="/path"
APPSERVERFLAG="/path"

upload_file () {
cd $DATADIR
echo "open $FTPSITE $FTPPORT" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $FTPUPLOADDIR" >> $SCRIPTDIR/ftptask.txt
echo "put  $1" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs.log 2>&1
rm -rf $SCRIPTDIR/ftptask.txt

}

checkftp () {
echo "open $FTPSITE $FTPPORT" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $FTPUPLOADDIR" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt | grep "Login successful" >> $SCRIPTDIR/logs.log 2>&1
if [ $? -eq 0 ]
then
    echo "OK"
else
    echo "fail"
fi
}

del_flag () {
/usr/local/bin/plink -l $APPSERVERNAME -pw $APPSERVERPASS $APPSERVERNAME@$APPSERVER rm  $APPSERVERFLAG/$1

}

################################################
echo "-----------------此脚本为上传文件到FTP Server的脚本,`date "+%Y-%m-%d_%H:%M:%S"`--------------"  >> $SCRIPTDIR/logs.log
echo "check FTP Server status" >> $SCRIPTDIR/logs.log
gctftpstatus="`checkftp`"
if [ $gctftpstatus = "OK" ]
then
    echo "FTP服务器OK" >> $SCRIPTDIR/logs.log
else
    echo "FTP服务器不可用" >> $SCRIPTDIR/logs.log
    for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
    do
        echo "FTP服务器不可用,脚本部署服务器:xxx.xxx.xxx.xxx,/path/FTP_upload.sh" | mutt -s "FTP服务器不可用" $user
    done
    exit 1
fi
echo "check $APPSERVER server flag file exist....." >> $SCRIPTDIR/logs.log
/usr/local/bin/plink  -l $APPSERVERNAME -pw $APPSERVERPASS $APPSERVERNAME@$APPSERVER ls $APPSERVERFLAG > $SCRIPTDIR/uptemp.txt ; >> $SCRIPTDIR/logs.log 2>&1

if [ -s $SCRIPTDIR/uptemp.txt ]
then
    echo "file exist" >> $SCRIPTDIR/logs.log 2>&1
    for flagfile in `cat $SCRIPTDIR/uptemp.txt`
    do
        cd $DATADIR
        DATAFILEtemp="`echo $flagfile | awk -F[.-] '{print $2}'`"
        /usr/local/bin/pscp -l $APPSERVERNAME -pw $APPSERVERPASS $APPSERVERNAME@$APPSERVER:$APPSERVERDATA/trans-data-$DATAFILEtemp.txt $DATADIR >> $SCRIPTDIR/logs.log 2>&1
        zip trans-data-$DATAFILEtemp.ZIP trans-data-$DATAFILEtemp.txt >> $SCRIPTDIR/logs.log 2>&1
        sleep 2
        upload_file trans-data-$DATAFILEtemp.ZIP
        del_flag $flagfile
        rm -rf trans-data-$DATAFILEtemp.txt
    done
else
    echo "文件未上传到FTP Server,`date "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log 2>&1
    for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
    do
        echo "Send mail to ${user}..." >> $SCRIPTDIR/logs.log 2>&1
        echo "文件未上传到FTP Server,xxx.xxx.xxx.xxx,/path/FTP_upload.sh:`date "+%Y-%m-%d"`"  | mutt -s "文件未上传到FTP Server:`date "+%Y-%m-%d"`"  $user
    done
fi
rm -rf $SCRIPTDIR/uptemp.txt
