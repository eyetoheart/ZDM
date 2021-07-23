#!/bin/sh

LANG=zh_CN.GBK
export LANG
SCRIPTDIR="/path"
BACKUPDIR="/path"

DATEFORMAT="`date -d '-0 day' "+%Y%m%d%H%M%S"`"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVERUSER="name"
APPSERVERPASS='password'
APPSERVERFILE="/path"
APPSERVERFLAG="/path"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPASS="passwd"
REMOTE_UPLOAD_DIR="/path"

##############Define Function,creat file list of remote server,and save local file######################
ftp_up_file () {

cd $SCRIPTDIR
echo "open $FTPSITE" > $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "verbose" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "binary" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "passive" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "cd $1" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "mput $2" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "close" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
echo "bye" >> $SCRIPTDIR/up_bams_cash_ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/up_bams_cash_ftptask.txt >> $SCRIPTDIR/up_bams_cash.log 2>&1
rm $SCRIPTDIR/up_bams_cash_ftptask.txt

}

check_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER ls $APPSERVERFLAG > $SCRIPTDIR/bams_cash_flag_up.txt

}

delete_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER rm $APPSERVERFLAG/$1 >> $SCRIPTDIR/up_bams_cash.log 2>&1

}

getfiletolocal () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER:$APPSERVERFILE/$1 $SCRIPTDIR/$1 >> $SCRIPTDIR/up_bams_cash.log  2>&1

}

creat_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER touch $APPSERVERUPFLAG/$1 >> $SCRIPTDIR/up_bams_cash.log 2>&1

}

echo "---------------------------------此脚本从应用服务器$APPSERVER下载文件,并上传到$FTPSITE的脚本,`date "+%Y-%m-%d_%H:%M:%S"`:up_bams_cash.sh----------------------"  >> $SCRIPTDIR/up_bams_cash.log
echo "登录系统 Server,检查Server服务器上的$APPSERVERFLAG目录下是否有标志文件,将文件列表存入本地$SCRIPTDIR/bams_cash_flag_up.txt文件中" >> $SCRIPTDIR/up_bams_cash.log
check_flag >> $SCRIPTDIR/up_bams_cash.log 2>&1
cd $SCRIPTDIR
if [ -s $SCRIPTDIR/bams_cash_flag_up.txt ]
then
    echo "$APPSERVER的$APPSERVERFLAG目录下存在标志文件,现在将Server上$APPSERVERFILE目录下的相应文件下载到本地..." >> $SCRIPTDIR/up_bams_cash.log
    for i in  `cat $SCRIPTDIR/bams_cash_flag_up.txt`
    do
        cd $SCRIPTDIR
        getfiletolocal $i
        BUSI="`echo $i | awk -F[_] '{print $2}'`"
        echo "将$i文件压缩后通过FTP上传到$FTPSITE服务器的$REMOTE_UPLOAD_DIR/$BUSI目录下..." >> $SCRIPTDIR/up_bams_cash.log
        zip  ${i}.zip  $i  >> $SCRIPTDIR/up_bams_cash.log
        ftp_up_file  $REMOTE_UPLOAD_DIR/$BUSI  ${i}.zip
        echo "备份$i文件到本地$BACKUPDIR目录中..."  >> $SCRIPTDIR/up_bams_cash.log
        tar rvf $BACKUPDIR/up_bams_cash_${DATEFORMAT}.tar $i >> $SCRIPTDIR/up_bams_cash.log  2>&1
        echo "删除$APPSERVER服务器$APPSERVERFLAG目录下的标志文件..." >> $SCRIPTDIR/up_bams_cash.log
        delete_flag  $i
        rm -rf $i >> $SCRIPTDIR/up_bams_cash.log  2>&1
        rm -rf ${i}.zip >> $SCRIPTDIR/up_bams_cash.log  2>&1
        
    done
    rm -rf bams_cash_flag_up.txt
else
    rm -rf bams_cash_flag_up.txt
fi
