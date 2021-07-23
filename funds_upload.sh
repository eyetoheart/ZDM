#!/bin/sh

LANG=zh_CN.GBK
export LANG
SCRIPTDIR="/path"
BACKUPDIR="/path"

DATEFORMAT="`date -d '-0 day' "+%Y%m%d%H%M%S"`"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVERUSER="access"
APPSERVERPASS='passwd'
APPSERVERFILE="/path"
APPSERVERFLAG="/path"
APPSERVERUPFLAG="/path"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPASS="passwd"
REMOTE_UPLOAD_DIR="/path"

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

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER ls $APPSERVERFLAG > $SCRIPTDIR/flag_up.txt

}

delete_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER rm $APPSERVERFLAG/$1 >> $SCRIPTDIR/logs_ftpup.log 2>&1

}

getfiletolocal () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER:$APPSERVERFILE/$1 $SCRIPTDIR/$1 >> $SCRIPTDIR/logs_ftpup.log  2>&1

}

creat_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER touch $APPSERVERUPFLAG/$1 >> $SCRIPTDIR/logs_ftpup.log 2>&1

}

echo "---------------------------------此脚本为应用服务器$APPSERVER下载文件,并上传到$FTPSITE的脚本,`date "+%Y-%m-%d_%H:%M:%S"`:funds_upload.sh----------------------"  >> $SCRIPTDIR/logs_ftpup.log
echo "登录系统 Server,检查系统Server服务器上的$APPSERVERFLAG目录下是否有标志文件,将文件列表存入本地$SCRIPTDIR/flag_up.txt文件中" >> $SCRIPTDIR/logs_ftpup.log
check_flag >> $SCRIPTDIR/logs_ftpup.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/flag_up.txt ]
then
    echo "$APPSERVER的$APPSERVERFLAG目录下存在标志文件,现在将Server上$APPSERVERFILE目录下的相应文件下载到本地..." >> $SCRIPTDIR/logs_ftpup.log
    for i in  `cat $SCRIPTDIR/flag_up.txt`
    do
        cd $SCRIPTDIR
        getfiletolocal $i
        BUSI="`echo $i | awk -F[_] '{print $2}'`"
        echo "将$i文件通过FTP上传到$FTPSITE服务器的$REMOTE_UPLOAD_DIR/$BUSI目录下..." >> $SCRIPTDIR/logs_ftpup.log
        zip  ${i}.zip  $i  >> $SCRIPTDIR/logs_ftpup.log
        ftp_up_file  $REMOTE_UPLOAD_DIR/$BUSI  ${i}.zip
        echo "备份$i文件到本地$BACKUPDIR目录中..."  >> $SCRIPTDIR/logs_ftpup.log
        tar rvf $BACKUPDIR/funds_up_${DATEFORMAT}.tar $i >> $SCRIPTDIR/logs_ftpup.log  2>&1
        echo "创建一个标志文件，并将此标志文件放到$FTPSITE服务器的$REMOTE_UPLOAD_DIR/${BUSI}Flag目录下" >> $SCRIPTDIR/logs_ftpup.log
        echo "" > $i
        ftp_up_file $REMOTE_UPLOAD_DIR/${BUSI}Flag  $i
        echo "在$APPSERVER服务器的$APPSERVERUPFLAG目录下创建标志文件..." >> $SCRIPTDIR/logs_ftpup.log
        creat_flag  $i
        echo "删除$APPSERVER服务器$APPSERVERFLAG目录下的标志文件..." >> $SCRIPTDIR/logs_ftpup.log
        delete_flag  $i
        rm -rf $i >> $SCRIPTDIR/logs_ftpup.log  2>&1
        rm -rf ${i}.zip
        
    done
    rm -rf flag_up.txt
else
    rm -rf flag_up.txt
fi
