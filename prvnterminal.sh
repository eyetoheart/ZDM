#!/bin/sh

###################Define Envionment Variables########
SCRIPTDIR="/path"
LANG=zh_CN.UTF-8
export LANG
DATAFORMAT="`date +"%Y-%m-%d"`"

JXPSFTP="xxx.xxx.xxx.xxx"
JXPSFTPUSER="access"
JXPSFTPPASS="passwd"
JXPSFTPSELLPATH="/path"
JXPSFTPWINPATH="/path"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVER_USER="access"
APPSERVER_PASS='passwd'
APPSELLPATH="/path"
APPWINPATH="/path"

##############Define Function,down file from remote server##################
down_file () {

cd $SCRIPTDIR
echo "open $JXPSFTP" > $SCRIPTDIR/ftptask.txt
echo "user $JXPSFTPUSER $JXPSFTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $1" >> $SCRIPTDIR/ftptask.txt
echo "mget $2" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs.log 2>&1
rm $SCRIPTDIR/ftptask.txt

}

delete_remote_file () {

cd $SCRIPTDIR
echo "open $JXPSFTP" > $SCRIPTDIR/ftptask.txt
echo "user $JXPSFTPUSER $JXPSFTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $1" >> $SCRIPTDIR/ftptask.txt
echo "delete  $2" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs.log 2>&1
rm $SCRIPTDIR/ftptask.txt

}

creat_remote_filelist () {

cd $SCRIPTDIR
echo "open $JXPSFTP" > $SCRIPTDIR/ftptask.txt
echo "user $JXPSFTPUSER $JXPSFTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $1" >> $SCRIPTDIR/ftptask.txt
echo "mls *.txt  $SCRIPTDIR/$2"  >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs.log 2>&1
rm $SCRIPTDIR/ftptask.txt
}

up_data_file () {

/usr/local/bin/pscp -l $APPSERVER_USER -pw $APPSERVER_PASS $SCRIPTDIR/$2  $APPSERVER_USER@$APPSERVER:$1/$2 >> $SCRIPTDIR/logs.log 2>&1

}

up_flag_file () {

/usr/local/bin/plink -l $APPSERVER_USER -pw $APPSERVER_PASS $APPSERVER_USER@$APPSERVER touch $1/$2 >> $SCRIPTDIR/logs.log 2>&1

}

echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+此脚本为从Agent服务器的FTP Server上下载数据文件-`date "+%Y-%m-%d_%H:%M:%S"`+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+" >> $SCRIPTDIR/logs.log

echo "登陆PS项目Agent FTP Server,将远程服务器上文件列表存在本地$SCRIPTDIR/selltemp.txt文件中"  >> $SCRIPTDIR/logs.log
creat_remote_filelist $JXPSFTPSELLPATH/flag  selltemp.txt
cd $SCRIPTDIR
if [ ! -s $SCRIPTDIR/selltemp.txt ]
then
    echo "没有需要下载的文件:`date "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
else
    echo "Agent FTP Server上有文件需要下载......" >> $SCRIPTDIR/logs.log
    for i in `cat $SCRIPTDIR/selltemp.txt`
    do
        cd  $SCRIPTDIR
        FILENAME="`echo $i | awk -F. '{print $1}'`"
        EXTNAME="`echo $i | awk -F. '{print $2}'`"
        echo "开始下载$i文件......" >> $SCRIPTDIR/logs.log
        down_file $JXPSFTPSELLPATH  $i
        echo "将下载的文件放到应用服务器$APPSERVER目录$APPSELLPATH/file中" >> $SCRIPTDIR/logs.log
        up_data_file  $APPSELLPATH/file  $i
        echo "在应用服务器$APPSERVER的$APPSELLPATH/flag目录创建标志文件:${FILENAME}_flag.${EXTNAME}"  >> $SCRIPTDIR/logs.log
        up_flag_file $APPSELLPATH/flag   ${FILENAME}_flag.${EXTNAME}
        echo "删除Agent服务器FTP Server上的标志文件:$i" >> $SCRIPTDIR/logs.log
        delete_remote_file $JXPSFTPSELLPATH/flag  $i
        rm -rf $i
        echo "下载文件的任务结束:`date "+%Y-%m-%d_%H:%M:%S"`"  >> $SCRIPTDIR/logs.log
    done
fi
cd $SCRIPTDIR
rm -rf selltemp.txt

echo "------------------------------------------------" >> $SCRIPTDIR/logs.log

echo "登陆PS项目Agent FTP Server,将远程服务器上文件列表存在本地$SCRIPTDIR/wintemp.txt文件中"  >> $SCRIPTDIR/logs.log
creat_remote_filelist $JXPSFTPWINPATH/flag  wintemp.txt
cd $SCRIPTDIR
if [ ! -s $SCRIPTDIR/wintemp.txt ]
then
    echo "没有需要下载的文件:`date "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
else
    echo "Agent FTP Server上有文件需要下载......" >> $SCRIPTDIR/logs.log
    for i in `cat $SCRIPTDIR/wintemp.txt`
    do
        cd $SCRIPTDIR
        FILENAME="`echo $i | awk -F. '{print $1}'`"
        EXTNAME="`echo $i | awk -F. '{print $2}'`"
        echo "开始下载$i文件......" >> $SCRIPTDIR/logs.log
        down_file $JXPSFTPWINPATH  $i
        echo "将下载的文件放到应用服务器$APPSERVER目录$APPWINPATH/file中" >> $SCRIPTDIR/logs.log
        up_data_file   $APPWINPATH/file  $i
        echo "在应用服务器$APPSERVER的$APPWINPATH/flag目录创建标志文件:${FILENAME}_flag.${EXTNAME}"  >> $SCRIPTDIR/logs.log
        up_flag_file $APPWINPATH/flag  ${FILENAME}_flag.${EXTNAME}
        echo "删除Agent服务器FTP Server上的标志文件:$i" >> $SCRIPTDIR/logs.log
        delete_remote_file $JXPSFTPWINPATH/flag  $i
        rm -rf $i
        echo "下载文件的任务结束:`date "+%Y-%m-%d_%H:%M:%S"`"  >> $SCRIPTDIR/logs.log
    done
fi
cd $SCRIPTDIR
rm -rf wintemp.txt
