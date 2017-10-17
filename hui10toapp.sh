#!/bin/sh

#############################################
## file name : hui10toapp.sh
## creator:zhangdm
## create time:2017-05-05
## modify time:2017-05-05
## copyright (C) BeiJing IWT Technology Ltd.
#############################################
LANG=zh_CN.UTF-8
export LANG
SCRIPTDIR="/path"
BACKUPDIR="/path"
RECORDFILE="/path"

DATEFORMAT="`date -d '-1 day' "+%Y%m%d"`"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVERUSER="access"
APPSERVERPASS='passwd'
APPSERVER_FILE="/path"
APPSERVER_FLAG="/path"

HUI10SERVER="xxx.xxx.xxx.xxx"
HUI10SERVERUSER="access"
HUI10SERVERPASS="passwd"
HUI10SERVERPATH="/path"

LOCALDIR="/path"

##############Define Function,creat file list of remote server,and save local file######################

downfilefromhui10 () {

/usr/local/bin/pscp -l $HUI10SERVERUSER -pw $HUI10SERVERPASS $HUI10SERVERUSER@$HUI10SERVER:$HUI10SERVERPATH/727623788293994929-$DATEFORMAT.txt  $SCRIPTDIR/727623788293994929-$DATEFORMAT.txt  >> $SCRIPTDIR/logs.log  2>&1

}

upfiletoapp () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS  $2  $APPSERVERUSER@$APPSERVER:$1/$2 >> $SCRIPTDIR/logs.log  2>&1

}

creat_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER touch $1/$2 >> $SCRIPTDIR/logs.log 2>&1

}

echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-此脚本的功能将服务器$HUI10SERVER的$HUI10SERVERPATH目录下产生的文件传输到$APPSERVER服务器的$APPSERVER_FILE目录下,并在$APPSERVER_FLAG目录下产生标志文件" >> $SCRIPTDIR/logs.log
echo "------检查今天是否已经下载过文件,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.log
cd  $SCRIPTDIR
grep  $DATEFORMAT  $RECORDFILE >> $SCRIPTDIR/logs.log  2>&1
[ $? -eq 0 ] && { echo "文件727623788293994929-$DATEFORMAT.txt已经下载过了,不用再重复下载了" >> $SCRIPTDIR/logs.log ; exit 0 ; }

downfilefromhui10

if [ -f $SCRIPTDIR/727623788293994929-$DATEFORMAT.txt ]
then
    echo "已经在服务器$HUI10SERVER下载到文件727623788293994929-$DATEFORMAT.txt,现在将文件传输到$APPSERVER服务器的$APPSERVER_FILE目录下,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.log
    upfiletoapp  $APPSERVER_FILE  727623788293994929-$DATEFORMAT.txt
    if [ $? -eq 0 ]
    then
        FLAG_FILE_NAME="727623788293994929-${DATEFORMAT}_flag.txt"
        echo "现在将标志文件上传到$APPSERVER服务器的$APPSERVER_FLAG目录下,`date "+%Y-%m-%d_%H:%M:%S"`..."  >> $SCRIPTDIR/logs.log
        creat_flag  $APPSERVER_FLAG  $FLAG_FILE_NAME
        echo "现在将$i文件备份到$BACKUPDIR目录下" >> $SCRIPTDIR/logs.log
        zip   $BACKUPDIR/hui10ftp_${DATEFORMAT}.ZIP  727623788293994929-$DATEFORMAT.txt >> $SCRIPTDIR/logs.log  2>&1
        echo "727623788293994929-$DATEFORMAT.txt:`date "+%Y-%m-%d_%H:%M:%S"`" >> $RECORDFILE
        rm -rf 727623788293994929-$DATEFORMAT.txt
    else
        echo "将文件传给$APPSERVER失败,请检查$APPSERVER服务器状态是否正常" >> $SCRIPTDIR/logs.log  2>&1
    fi
else
    echo "服务器上还没有生成文件" >> $SCRIPTDIR/logs.log
fi
