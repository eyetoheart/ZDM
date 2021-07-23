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

echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-此脚本为在应用服务器$APPSERVER下载文件,并上传到$FTPSITE的脚本,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"  >> $SCRIPTDIR/logs_ftpup.log
echo "-----------------------------登录系统 Server,检查Server服务器上的$APPSERVER_CHECK_CWL_FLAG目录下是否有标志文件,将文件列表存入本地$SCRIPTDIR/flag_up.txt文件中-----------------------------------" >> $SCRIPTDIR/logs_ftpup.log
check_flag  $APPSERVER_CHECK_CWL_FLAG >> $SCRIPTDIR/logs_ftpup.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/flag_up.txt ]
then
    echo "$APPSERVER的$APPSERVER_CHECK_CWL_FLAG目录下存在标志文件,现在将Server上$APPSERVER_CHECK_CWL_FILE目录下的相应文件下载到本地..." >> $SCRIPTDIR/logs_ftpup.log
    for i in  `cat $SCRIPTDIR/flag_up.txt`
    do
        echo "get data:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal $APPSERVER_CHECK_CWL_FILE  $i
        echo "将$i文件压缩后,通过FTP上传到$FTPSITE服务器的$REMOTE_UPLOAD_CWL_DIR目录下..." >> $SCRIPTDIR/logs_ftpup.log
        zip ${i}.zip  $i >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_CWL_FILE  ${i}.zip
        echo "备份$i文件到本地$BACKUPDIR目录中..."  >> $SCRIPTDIR/logs_ftpup.log
        tar rvf $BACKUPDIR/check_up_cwl_$DATEFORMAT.tar $i >> $SCRIPTDIR/logs_ftpup.log  2>&1
        rm -rf $i
        echo "get flag:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal $APPSERVER_CHECK_CWL_FLAG  $i
        echo "将本地的标志文件$i上传到$FTPSITE服务器的$REMOTE_UPLOAD_CWL_FLAG目录下" >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_CWL_FLAG  $i
        echo "删除$APPSERVER服务器$APPSERVERFLAG目录下的标志文件..." >> $SCRIPTDIR/logs_ftpup.log
        delete_flag  $APPSERVER_CHECK_CWL_FLAG  $i
        rm -rf $i
        rm -rf ${i}.zip
    done
    rm -rf flag_up.txt
else
    rm -rf flag_up.txt
fi


echo "-----------------------------登录系统 Server,检查Server服务器上的$APPSERVER_CHECK_FUNDS_RESULT_FLAG 目录下是否有标志文件,将文件列表存入本地$SCRIPTDIR/flag_up.txt文件中-----------------------------------" >> $SCRIPTDIR/logs_ftpup.log
check_flag  $APPSERVER_CHECK_FUNDS_RESULT_FLAG >> $SCRIPTDIR/logs_ftpup.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/flag_up.txt ]
then
    echo "$APPSERVER的$APPSERVER_CHECK_FUNDS_RESULT_FLAG目录下存在标志文件,现在将Server上$APPSERVER_CHECK_FUNDS_RESULT__FILE目录下的相应文件下载到本地..." >> $SCRIPTDIR/logs_ftpup.log
    for i in  `cat $SCRIPTDIR/flag_up.txt`
    do
        echo "get data:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal  $APPSERVER_CHECK_FUNDS_RESULT_FILE  $i
        echo "将$i文件压缩后,通过FTP上传到$FTPSITE服务器的$REMOTE_UPLOAD_FUNDS_RESULT_DIR目录下..." >> $SCRIPTDIR/logs_ftpup.log
        zip ${i}.zip  $i >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_FUNDS_RESULT_FILE  ${i}.zip
        echo "备份$i文件到本地$BACKUPDIR目录中..."  >> $SCRIPTDIR/logs_ftpup.log
        tar rvf $BACKUPDIR/check_up_funds_result_$DATEFORMAT.tar $i >> $SCRIPTDIR/logs_ftpup.log  2>&1
        rm -rf $i
        echo "get flag:$i" >> $SCRIPTDIR/logs_ftpup.log
        getfiletolocal  $APPSERVER_CHECK_FUNDS_RESULT_FLAG  $i
        echo "将本地的标志文件$i上传到$FTPSITE服务器的$REMOTE_UPLOAD_FUNDS_RESULT_FLAG目录下" >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_FUNDS_RESULT_FLAG  $i
        echo "删除$APPSERVER服务器$APPSERVERFLAG目录下的标志文件..." >> $SCRIPTDIR/logs_ftpup.log
        delete_flag  $APPSERVER_CHECK_FUNDS_RESULT_FLAG  $i
        rm -rf $i
        rm -rf ${i}.zip
    done
    rm -rf flag_up.txt
else
    rm -rf flag_up.txt
fi
