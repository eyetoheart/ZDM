#!/bin/sh

#####################################################
## file name : scan_lj_up.sh
## creator:zhangdm
## create time:2016-08-26
## modify time:2017-04-25
## copyright (C) Innovative World Technology Co.,Ltd.
#####################################################

###################Define Envionment Variables########
LANG=zh_CN.UTF-8
export LANG
SCRIPTDIR="/path"
DATEDAY="`date -d '-0 day' "+%Y-%m-%d_%H-%M"`"

FTPSITE="xxx.xxx.xxx.xxx"
FTPUSER="access"
FTPPASS="passwd"
REMOTE_UPLOCAL_DIR="/path"

APPSERVER="xxx.xxx.xxx.xxx"
APPSERVER_USER="access"
APPSERVER_PASS='passwd'
APPSERVER_DATA_DIR="/path"
APPSERVER_FLAG_DIR="/path"
APPSERVER_BAK_DIR="/path"

##############Define Function,creat file list of remote server,and save local file######################
check_flag_file () {

/usr/local/bin/pscp -l $APPSERVER_USER -pw $APPSERVER_PASS  $APPSERVER_USER@$APPSERVER:$APPSERVER_FLAG_DIR/33_*_*_flag.txt  $SCRIPTDIR  >> $SCRIPTDIR/logs_lj.log 2>&1

}

bak_data_file () {

/usr/local/bin/plink -l $APPSERVER_USER -pw $APPSERVER_PASS  $APPSERVER_USER@$APPSERVER zip $APPSERVER_BAK_DIR/SCAN_LJ_UP_$DATEDAY.ZIP $APPSERVER_DATA_DIR/$1 >> $SCRIPTDIR/logs_lj.log 2>&1 
/usr/local/bin/plink -l $APPSERVER_USER -pw $APPSERVER_PASS  $APPSERVER_USER@$APPSERVER rm -rf $APPSERVER_DATA_DIR/$1 >> $SCRIPTDIR/logs_lj.log 2>&1

}

del_flag_file () {

/usr/local/bin/plink -l $APPSERVER_USER -pw $APPSERVER_PASS  $APPSERVER_USER@$APPSERVER rm -rf $APPSERVER_FLAG_DIR/$1 >> $SCRIPTDIR/logs_lj.log 2>&1 

} 

down_data_file () {

/usr/local/bin/pscp -l $APPSERVER_USER -pw $APPSERVER_PASS  $APPSERVER_USER@$APPSERVER:$APPSERVER_DATA_DIR/$1  $SCRIPTDIR  >> $SCRIPTDIR/logs_lj.log  2>&1

}

ftp_upload_file () {

cd $SCRIPTDIR
echo "open $FTPSITE" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $REMOTE_UPLOCAL_DIR" >> $SCRIPTDIR/ftptask.txt
echo "put  $1" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/logs_lj.log 2>&1
rm -rf $SCRIPTDIR/ftptask.txt

}

echo "-+-+-+-+-+-+-+-+-+-+此脚本为将文件上传给系统的脚本,`date "+%Y-%m-%d_%H:%M:%S"`-+-+-+-+-+-+-+-+--+-+-+-+-+-+-+-+-+" >> $SCRIPTDIR/logs_lj.log
echo "检查应用服务器是否存在需要上传的文件......." >> $SCRIPTDIR/logs_lj.log
cd $SCRIPTDIR
check_flag_file
ls -1 33_*_*_flag.txt > $SCRIPTDIR/ljuptemp.txt 2>> $SCRIPTDIR/logs_lj.log 
sed -i '/33004/d'  $SCRIPTDIR/ljuptemp.txt

[ ! -s $SCRIPTDIR/ljuptemp.txt ] && { rm -rf $SCRIPTDIR/ljuptemp.txt >> $SCRIPTDIR/logs_lj.log 2>&1 ; exit 0 ; }

echo "存在需要上传给的文件，现在开始从应用服务器上下载到本地......." >> $SCRIPTDIR/logs_lj.log
for i  in  `cat $SCRIPTDIR/ljuptemp.txt`
do
    DATAFILE="`echo $i | awk -F[_.] '{print $1"_"$2"_"$3".txt"}'`"
    ZDATAFILE="`echo $i | awk -F[_.] '{print $1"_"$2"_"$3".txt.ZIP"}'`"
    grep ok $i >> $SCRIPTDIR/logs_lj.log 2>&1
    if [ $? -eq 0 ]
    then
        echo "开始下载$DATAFILE文件到本,`date "+%Y-%m-%d_%H:%M:%S"`..."  >> $SCRIPTDIR/logs_lj.log
        down_data_file $DATAFILE
        echo "压缩数据文件,`date "+%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs_lj.log
        zip $ZDATAFILE  $DATAFILE >> $SCRIPTDIR/logs_lj.log  2>&1
        echo "将扫码文件上传给,`date "+%Y-%m-%d_%H:%M:%S"`......." >> $SCRIPTDIR/logs_lj.log
        ftp_upload_file $ZDATAFILE
        echo "备份$DATAFILE到应用服务器的$APPSERVER_BAK_DIR目录下,`date "+%Y-%m-%d_%H:%M:%S"`......." >> $SCRIPTDIR/logs_lj.log
        bak_data_file $DATAFILE
        echo "删除应用服务器上$APPSERVER_FLAG_DIR目录下的标志文件$i......." >> $SCRIPTDIR/logs_lj.log
        del_flag_file $i
        rm -rf $SCRIPTDIR/$i
        rm -rf $SCRIPTDIR/$DATAFILE
        rm -rf $SCRIPTDIR/$ZDATAFILE
    else
        echo "因标志文件$i有问题而导致文件$DATAFILE没有上传给FTP服务器，请检查应用服务器$APPSERVER,是否正确生成了相关数据" >> $SCRIPTDIR/logs_lj.log
        rm -rf $SCRIPTDIR/$i
    fi
done
rm -rf $SCRIPTDIR/ljuptemp.txt
