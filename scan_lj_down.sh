#!/bin/sh

#####################################################
## file name : scan_lj_down.sh
## creator:zhangdm
## create time:2016-09-06
## modify time:2017-04-25
## copyright (C) Innovative World Technology Co.,Ltd.
#####################################################

###################Define Envionment Variables########
LANG=zh_CN.UTF-8
export LANG
SCRIPTDIR="/path"
LOCALDATADIR="/path"
CONFIGFILE="/path"
RECORDFILE="/path"
DATEDAY="`date -d '-1 day' "+%Y-%m-%d_%H-%M"`"
DATEDAYFORMAT="`date -d '-1 day' "+%Y-%m-%d"`"
YESTERDAY="`date -d '-2 day' "+%Y-%m-%d"`"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPASS="passwd"
REMOTE_DOWN_DIR="/path"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVER_USER="access"
APPSERVER_PASS='passwd'
APPSERVER_DATA_DIR="/path"
APPSERVER_FLAG_DIR="/path"
APPSERVER_BAK_DIR="/path"

##############Define Function,creat file list of remote server,and save local file######################
ftp_down_file () {

cd $SCRIPTDIR
echo "open $FTPSITE" > $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "verbose" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "binary" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "cd $REMOTE_DOWN_DIR" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "get  $1" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "close" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "bye" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/scan_lj_down_ftptask.txt >> $SCRIPTDIR/logs_lj.log 2>&1
rm -rf $SCRIPTDIR/scan_lj_down_ftptask.txt

}

ftp_list_file () {

cd $SCRIPTDIR
echo "open $FTPSITE" > $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "verbose" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "binary" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "cd $REMOTE_DOWN_DIR" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "mls  $1  $SCRIPTDIR/ljlist.txt" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "close" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
echo "bye" >> $SCRIPTDIR/scan_lj_down_ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/scan_lj_down_ftptask.txt >> $SCRIPTDIR/logs_lj.log 2>&1
rm -rf $SCRIPTDIR/scan_lj_down_ftptask.txt

}

up_data_file () {

/usr/local/bin/pscp -l $APPSERVER_USER -pw $APPSERVER_PASS $SCRIPTDIR/$1  $APPSERVER_USER@$APPSERVER:$APPSERVER_DATA_DIR/$1 >> $SCRIPTDIR/logs_lj.log 2>&1

}

up_flag_file () {

/usr/local/bin/pscp -l $APPSERVER_USER -pw $APPSERVER_PASS $SCRIPTDIR/$1  $APPSERVER_USER@$APPSERVER:$APPSERVER_FLAG_DIR/$1 >> $SCRIPTDIR/logs_lj.log 2>&1

}

sendmailtouser () { 

cd $SCRIPTDIR
for i in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
        echo "now start send mail to $i,time is `date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs_lj.log
        echo "Z项目昨天文件$1没有下载到本地，请联系相关人员检查系统"| mutt -s "Z项目昨天文件$1未下载成功:`date "+%Y-%m-%d_%H:%M:%S"`"  $i
done

}

echo "-+-+-+-+-+-+-+-+-+-+此脚本为从FTP服务器上下载文件的脚本,并将文件上传到服务器,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+-+-+--+-+-+-+-+-+-+-+-+" >> $SCRIPTDIR/logs_lj.log
echo "检查昨天的文件是否全部下载到本地，并上传到服务器......." >> $SCRIPTDIR/logs_lj.log

cd $SCRIPTDIR
for i in `grep $YESTERDAY  $CONFIGFILE | awk -F[,] '$2 !~ /33004/ {print $1"_"$2"_"$3}'`
do
    YSCAN="${i}_result.txt.ZIP"
    grep  $YSCAN  $RECORDFILE >> $SCRIPTDIR/logs_lj.log 2>&1
    if [  $? -ne 0 ]
    then
        echo "昨天文件$YSCAN没有下载到本地，请联系相关人员检查系统" >> $SCRIPTDIR/logs_lj.log
        echo "$YSCAN:$DATEDAY:mail" >> $RECORDFILE
        sendmailtouser $YSCAN
    fi
done

cd $SCRIPTDIR
for i in `grep $DATEDAYFORMAT  $CONFIGFILE | awk -F[,] '$2 !~ /33004/ {print $1"_"$2"_"$3}'`
do
    SCAN="${i}_result.txt.ZIP"
    UNSCAN="${i}_result.txt"
    echo "现在检查FTP服务器是否存在$SCAN文件......." >> $SCRIPTDIR/logs_lj.log
    ftp_list_file $SCAN
    if [ ! -s $SCRIPTDIR/ljlist.txt ]
    then
        echo "FTP服务器上还没有生成$SCAN文件" >> $SCRIPTDIR/logs_lj.log
        continue
    else
        grep $SCAN $RECORDFILE >> $SCRIPTDIR/logs_lj.log 2>&1
        [ $? -eq 0 ] && { echo "文件$SCAN已经下载过了,不用再重复下载了" >> $SCRIPTDIR/logs_lj.log ; continue ; }
        echo "FTP服务器上存在需要下载的文件,现在开始下载到本地,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs_lj.log
        ftp_down_file $SCAN
        sleep 1
        unzip $SCAN >> $SCRIPTDIR/logs_lj.log 2>&1
        if [ -f $UNSCAN ]
        then
            echo "现在将$UNSCAN文件上传到$APPSERVER服务器的$APPSERVER_DATA_DIR目录下,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs_lj.log
            up_data_file $UNSCAN
            if [ $? -eq 0 ]
            then
                FLAGFILE="`echo $UNSCAN | awk -F. '{print $1"_flag.txt"}'`"
                echo "ok" > $SCRIPTDIR/$FLAGFILE
                echo "在$APPSERVER服务器的$APPSERVER_FLAG_DIR目录下生成标志文件,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs_lj.log
                cd $SCRIPTDIR
                up_flag_file $FLAGFILE
                rm -rf $FLAGFILE
            fi
        else
            echo "下载的压缩文件$SCAN解压后文件有误,请联系相关人员检查" >> $SCRIPTDIR/logs_lj.log
        fi
        echo "$SCAN:`date "+%Y-%m-%d_%H-%M"`" >> $RECORDFILE
        echo "现在将下载下来的$SCAN文件备份到本机$LOCALDATADIR目录的SCAN_LJ_DOWN_$DATEDAY.ZIP文件中" >> $SCRIPTDIR/logs_lj.log
        zip $LOCALDATADIR/SCAN_LJ_DOWN_$DATEDAY.ZIP $SCAN >> $SCRIPTDIR/logs_lj.log  2>&1
        echo "现在将备份文件:SCAN_LJ_DOWN_$DATEDAY.ZIP传输到$APPSERVER服务器的$APPSERVER_BAK_DIR目录下"  >> $SCRIPTDIR/logs_lj.log
        /usr/local/bin/pscp -l $APPSERVER_USER -pw $APPSERVER_PASS $LOCALDATADIR/SCAN_LJ_DOWN_$DATEDAY.ZIP  $APPSERVER_USER@$APPSERVER:$APPSERVER_BAK_DIR >> $SCRIPTDIR/logs_lj.log 2>&1
        rm -rf $SCRIPTDIR/$SCAN
        rm -rf $SCRIPTDIR/$UNSCAN
    fi
done
rm -rf $SCRIPTDIR/ljlist.txt
