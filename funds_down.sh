#!/bin/sh

#############################################
## file name : funds_down.sh
## creator:zhangdm
## create time:2017-05-08
## modify time:2017-05-08
## copyright (C) BeiJing IWT Technology Ltd.
#############################################
LANG=zh_CN.GBK
export LANG
SCRIPTDIR="/path"
BACKUPDIR="/path"

DATEFORMAT="`date -d '-0 day' "+%Y%m%d%H%M%S"`"

APPSERVER="xxx.xxx.xx.xxx"
APPSERVERUSER="access"
APPSERVERPASS='passwd'
APPSERVERFILE="/path"
APPSERVERFLAG="/path"
APPSERVERDOWNFLAG="/path"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPASS="passwd"
REMOTE_DOWN_DIR="/path"

##############Define Function,creat file list of remote server,and save local file######################
ftp_down_file () {

cd $SCRIPTDIR
echo "open $FTPSITE" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "passive" >> $SCRIPTDIR/ftptask.txt
echo "cd $1" >> $SCRIPTDIR/ftptask.txt
echo "mget $2" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs_ftpdown.log 2>&1
rm $SCRIPTDIR/ftptask.txt

}

check_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER ls $APPSERVERFLAG > $SCRIPTDIR/flag_down.txt

}

delete_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER rm $APPSERVERFLAG/$1 >> $SCRIPTDIR/logs_ftpdown.log 2>&1

}

upfiletoapp () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS  $SCRIPTDIR/$1  $APPSERVERUSER@$APPSERVER:$APPSERVERFILE >> $SCRIPTDIR/logs_ftpdown.log  2>&1

}

creat_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER touch $APPSERVERDOWNFLAG/$1 >> $SCRIPTDIR/logs_ftpdown.log 2>&1

}

echo "---------------------------------此脚本为从FTP Server下载文件的脚本,`date "+%Y-%m-%d_%H:%M:%S"`:funds_down.sh----------------------"  >> $SCRIPTDIR/logs_ftpdown.log
echo "登录系统 Server,检查Server服务器上的$APPSERVERFLAG目录下是否有标志文件,将文件列表存入本地$SCRIPTDIR/flag_down.txt文件中" >> $SCRIPTDIR/logs_ftpdown.log
check_flag >> $SCRIPTDIR/logs_ftpdown.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/flag_down.txt ]
then
    echo "$APPSERVER的$APPSERVERFLAG目录下存在标志文件,现在根据此标志文件通过FTP登陆到$FTPSITE下载文件" >> $SCRIPTDIR/logs_ftpdown.log
    for i in  `cat $SCRIPTDIR/flag_down.txt`
    do
        BUSI="`echo $i | awk -F[_] '{print $2}'`"
        ftp_down_file  $REMOTE_DOWN_DIR/$BUSI  ${i}.zip
        echo "将${i}.zip文件解压,并上传到$APPSERVER服务器的$APPSERVERFILE目录下..." >> $SCRIPTDIR/logs_ftpdown.log
        unzip  ${i}.ziap >> $SCRIPTDIR/logs_ftpdown.log
        upfiletoapp  $i
        echo "在$APPSERVER服务器的$APPSERVERDOWNFLAG目录下创建标志文件..." >> $SCRIPTDIR/logs_ftpdown.log
        creat_flag  $i
        echo "删除$APPSERVER服务器$APPSERVERFLAG目录下的标志文件..." >> $SCRIPTDIR/logs_ftpdown.log
        delete_flag  $i
        echo "备份$i文件到本地$BACKUPDIR目录中..."  >> $SCRIPTDIR/logs_ftpdown.log
        tar rvf $BACKUPDIR/funds_down_${DATEFORMAT}.tar $i >> $SCRIPTDIR/logs_ftpdown.log  2>&1
        rm -rf $i
        rm -rf ${i}.zip
        
    done
    rm -rf flag_down.txt
else
    rm -rf flag_down.txt
fi
