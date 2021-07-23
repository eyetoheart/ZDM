#!/bin/sh

###################Define Envionment Variables########
LANG=zh_CN.UTF-8
export LANG
SCRIPTDIR="/path"
LOCALDATADIR="/path"
RECORDFILE="/path/already_download_file_list.txt"
DATEDAY="`date -d '-0 day' "+%Y%m%d"`"
YESTERDAY="`date -d '-1 day' "+%Y%m%d"`"

FTPSITE="xxx.xxx.xxx.xxx"
FTPPORT="21"
FTPUSER="access"
FTPPASS="passwd"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVER_USER="access"
APPSERVER_PASS='passwd'
APPSERVER_DATA_DIR="/path"
APPSERVER_FLAG_DIR="/path"

##############Define Function,creat file list of remote server,and save local file######################
ftp_down_file () {

cd $SCRIPTDIR
echo "open $FTPSITE $FTPPORT" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $3" >> $SCRIPTDIR/ftptask.txt
echo "get  $1 $2" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs.log 2>&1
rm -rf $SCRIPTDIR/ftptask.txt

}

ftp_list_file () {

cd $SCRIPTDIR
echo "open $FTPSITE $FTPPORT" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "mls  $1  $SCRIPTDIR/list.txt" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs.log 2>&1
rm -rf $SCRIPTDIR/ftptask.txt

}

up_data_file () {

/usr/local/bin/pscp -l $APPSERVER_USER -pw $APPSERVER_PASS $SCRIPTDIR/$1  $APPSERVER_USER@$APPSERVER:$APPSERVER_DATA_DIR/$1 >> $SCRIPTDIR/logs.log 2>&1

}

up_flag_file () {

/usr/local/bin/plink -l $APPSERVER_USER -pw $APPSERVER_PASS $APPSERVER_USER@$APPSERVER touch $APPSERVER_FLAG_DIR/$1 >> $SCRIPTDIR/logs.log 2>&1

}

sendmailtouser () { 

cd $SCRIPTDIR
for i in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $i,time is `date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    echo "LS项目昨天${YESTERDAY}的文件$1未下载成功,请联系相关人员检查系统"| mutt -s "L S项目昨天${YESTERDAY}的文件$1未下载成功:`date "+%Y-%m-%d_%H:%M:%S"`"  $i
done

}

echo "-+-+-+-+-+-+-+-+-+-+此脚本是从FTP Server上下载文件的脚本:`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+-+-+--+-+-+-+-+-+-+-+-+" >> $SCRIPTDIR/logs.log
cd $SCRIPTDIR
echo "检查昨天的文件是否已经下载,并传输给$APPSERVER......" >> $SCRIPTDIR/logs.log
ftp_list_file $YESTERDAY
if [ ! -s $SCRIPTDIR/list.txt ]
then
    grep ${YESTERDAY} $RECORDFILE | grep mail >> $SCRIPTDIR/logs.log 2>&1
    if [ $? -ne 0 ]
    then
        echo "昨天${YESTERDAY}的文件未下载成功,请联系相关人员" >> $SCRIPTDIR/logs.log
        echo "${YESTERDAY}:mail" >> $RECORDFILE
        sendmailtouser
    fi
else
    echo "检查昨天的文件是否已经下载过......." >> $SCRIPTDIR/logs.log
    cd $SCRIPTDIR
    for i in `cat $SCRIPTDIR/list.txt`
    do
        filename="`echo $i | awk -F[./] '{print $2}'`"
        extname="`echo $i | awk -F[./] '{print $3}'`"
        grep ${filename}_${YESTERDAY}  $RECORDFILE  >> $SCRIPTDIR/logs.log 2>&1
        if [ $? -ne 0 ]
        then
            echo "昨天的文件${filename}_${YESTERDAY}.${extname}未下载成功,请联系相关人员" >> $SCRIPTDIR/logs.log
            echo "${filename}_${YESTERDAY}.${extname}:`date "+%Y-%m-%d_%H:%M:%S"`:mail" >> $RECORDFILE
            sendmailtouser ${filename}_${YESTERDAY}.${extname}
        fi
    done
fi

echo "将FTP Server上的文件列表保存到本地list.txt文件内......." >> $SCRIPTDIR/logs.log
ftp_list_file  $DATEDAY

if [ ! -s $SCRIPTDIR/list.txt ]
then
    echo "FTP Server上没有需要下载的文件"  >> $SCRIPTDIR/logs.log 2>&1
    cd $SCRIPTDIR
    rm -rf list.txt
else
    echo "FTP Server存在文件，检查此文件是否已经下载过......." >> $SCRIPTDIR/logs.log 2>&1
    cd $SCRIPTDIR
    for i in `cat $SCRIPTDIR/list.txt`
    do
        filename="`echo $i | awk -F[./] '{print $2}'`"
        extname="`echo $i | awk -F[./] '{print $3}'`"
        grep  ${filename}_${DATEDAY}  $RECORDFILE  >> $SCRIPTDIR/logs.log 2>&1
        if [ $? -eq 0 ]
        then
            echo "文件${filename}_${DATEDAY}.${extname},已经下载到本地,并传输给$APPSERVER......." >>  $SCRIPTDIR/logs.log 2>&1
            continue
        else
            echo "FTP Server上已经存在对账文件$i,并且尚未下载,现在开始下载并传输给$APPSERVER......." >> $SCRIPTDIR/logs.log 2>&1
            ftp_down_file ${filename}.${extname}  ${filename}_${DATEDAY}.${extname} $DATEDAY
            up_data_file  ${filename}_${DATEDAY}.${extname}
            up_flag_file  ${filename}_${DATEDAY}_flag.txt
            echo "将已经下载的文件写入already_download_file_list.txt文件" >> $SCRIPTDIR/logs.log
            echo "${filename}_${DATEDAY}.${extname}:`date "+%Y-%m-%d_%H:%M:%S"`" >> $RECORDFILE
            echo "将下载过的文件备份至${LOCALDATADIR}目录中" >>  $SCRIPTDIR/logs.log
            mv  ${filename}_${DATEDAY}.${extname}  $LOCALDATADIR
        fi
    done
    rm -rf list.txt
fi
