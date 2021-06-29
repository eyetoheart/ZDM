#!/bin/sh

#################
## 定义变量
#################
SCRIPTDIR="/opt/shell"
PMDOWNDIR="/data/hdfs/pmdataDownload"

DBSERVER="192.168.126.177"
DBPORT="3306"
DBUSER="root"
DBPASS='111111'
DBNAME="carrier_is"

LASTHOUR="`date -d '-1 hour' +%Y%m%d%H`"

COMMANDPSCP="/usr/local/bin"
COMMANDPLINK="/usr/local/bin"
COMMANDMYSQL="/usr/local/mysql/bin"

LANG=en_US.UTF-8
export LANG

#################
## 定义函数
#################
## 登录FTP服务器，下载所有匹配的文件
ftp_file_down_all () {

cd $PMDOWNDIR/$bxip
echo "open $bxip $bxport" > $SCRIPTDIR/ftptask.txt
echo "user $bxuser $bxpass" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
if [ $bxmode = "passive" ]
then
    echo "passive" >> $SCRIPTDIR/ftptask.txt
fi
echo "cd $bxpath/$LASTHOUR" >> $SCRIPTDIR/ftptask.txt
echo "mget *EUTRANCELLFDD*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "mget *EUTRANCELLTDD*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "mget *NSA-NRCellDU*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "mget *NSA-NRCellCU*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "mget *NSA-EUTRANCELLFDD*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "mget *NSA-EUTRANCELLTDD*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "mget *SA-NRCellDU*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "mget *SA-NRCellCU*$LASTHOUR*.gz" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/pm_get.log 2>&1
rm $SCRIPTDIR/ftptask.txt

}

#登录FTP服务器，下载某个给定字符串的相关文件
ftp_file_down_single () {

cd $PMDOWNDIR/$bxip
echo "open $bxip $bxport" > $SCRIPTDIR/ftptask.txt
echo "user $bxuser $bxpass" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
if [ $bxmode = "passive" ]
then
    echo "passive" >> $SCRIPTDIR/ftptask.txt
fi
echo "cd $bxpath/$LASTHOUR" >> $SCRIPTDIR/ftptask.txt
echo "mget $1" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/pm_get.log 2>&1
rm $SCRIPTDIR/ftptask.txt

}

#登录FTP服务器，列出服务器上指定目录的文件，并保存到本地文件中
ftp_file_list () {

cd $SCRIPTDIR
echo "open $bxip $bxport" > $SCRIPTDIR/ftptask.txt
echo "user $bxuser $bxpass" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
if [ $bxmode = "passive" ]
then
    echo "passive" >> $SCRIPTDIR/ftptask.txt
fi
echo "cd $bxpath/$LASTHOUR" >> $SCRIPTDIR/ftptask.txt
echo "mls *EUTRANCELLFDD*$LASTHOUR*.gz *EUTRANCELLTDD*$LASTHOUR*.gz *NSA-NRCellDU*$LASTHOUR*.gz *NSA-NRCellCU*$LASTHOUR*.gz *NSA-EUTRANCELLFDD*$LASTHOUR*.gz *NSA-EUTRANCELLTDD*$LASTHOUR*.gz *SA-NRCellDU*$LASTHOUR*.gz *SA-NRCellCU*$LASTHOUR*.gz ftp_file_list.txt" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/pm_get.log 2>&1
rm $SCRIPTDIR/ftptask.txt

}

#登录SFTP服务器，下载所有匹配的文件
ssh_file_down_all () {

cd $PMDOWNDIR/$bxip
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*EUTRANCELLFDD*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*EUTRANCELLTDD*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*NSA-NRCellDU*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*NSA-NRCellCU*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*NSA-EUTRANCELLFDD*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*NSA-EUTRANCELLTDD*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*SA-NRCellDU*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/*SA-NRCellCU*${LASTHOUR}*.gz ./ >> $SCRIPTDIR/pm_get.log 2>&1

}

#登录SFTP服务器，下载某个匹配的文件
ssh_file_down_single () {

cd $PMDOWNDIR/$bxip
$COMMANDPSCP/pscp -P $bxport -l $bxuser -pw $bxpass $bxuser@$bxip:$bxpath/$LASTHOUR/$1 ./ >> $SCRIPTDIR/pm_get.log 2>&1

}

#登录SFTP服务器，列出服务器上指定目录下的所有匹配文件列表，并保存到本地文件中
ssh_file_list () {

$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*EUTRANCELLFDD*${LASTHOUR}*.gz > $SCRIPTDIR/ssh_file_list.txt 2>/dev/null
$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*EUTRANCELLTDD*${LASTHOUR}*.gz >> $SCRIPTDIR/ssh_file_list.txt 2>/dev/null
$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*NSA-NRCellDU*${LASTHOUR}*.gz >> $SCRIPTDIR/ssh_file_list.txt 2>/dev/null
$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*NSA-NRCellCU*${LASTHOUR}*.gz >> $SCRIPTDIR/ssh_file_list.txt 2>/dev/null
$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*NSA-EUTRANCELLFDD*${LASTHOUR}*.gz >> $SCRIPTDIR/ssh_file_list.txt 2>/dev/null
$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*NSA-EUTRANCELLTDD*${LASTHOUR}*.gz >> $SCRIPTDIR/ssh_file_list.txt 2>/dev/null
$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*SA-NRCellDU*${LASTHOUR}*.gz >> $SCRIPTDIR/ssh_file_list.txt 2>/dev/null
$COMMANDPLINK/plink -P $bxport -no-antispoof -l $bxuser -pw $bxpass $bxuser@$bxip ls $bxpath/$LASTHOUR/*SA-NRCellCU*${LASTHOUR}*.gz >> $SCRIPTDIR/ssh_file_list.txt 2>/dev/null

}

echo "=======================================================================" >> $SCRIPTDIR/pm_get.log
echo "程序开始 <-------------------> 开始执行时间: `date`"                      >> $SCRIPTDIR/pm_get.log
echo "=======================================================================" >> $SCRIPTDIR/pm_get.log

$COMMANDMYSQL/mysql -A -h$DBSERVER -P$DBPORT -u$DBUSER -p$DBPASS $DBNAME -e "select * from downloadproperties where type = 'PM' order by vendor INTO outfile '$SCRIPTDIR/bxlist.txt' FIELDS terminated by '\|';" >> $SCRIPTDIR/pm_get.log 2>&1

for i in `cat $SCRIPTDIR/bxlist.txt`
do
    bxip="`echo $i | awk -F[\|] '{print $1}'`"
    bxport="`echo $i | awk -F[\|] '{print $2}'`"
    bxuser="`echo $i | awk -F[\|] '{print $3}'`"
    bxpass="`echo $i | awk -F[\|] '{print $4}'`"
    bxpath="`echo $i | awk -F[\|] '{print $5}'`"
    bxtype="`echo $i | awk -F[\|] '{print $6}'`"
    bxtimeout="`echo $i | awk -F[\|] '{print $7}'`"
    bxvendor="`echo $i | awk -F[\|] '{print $8}'`"
    bxcollecttype="`echo $i | awk -F[\|] '{print $9}'`"
    bxmode="`echo $i | awk -F[\|] '{print $10}'`"

    case $bxcollecttype in
    FTP|ftp)
    echo "北向服务器 $bxip 登录方式是FTP,检测本地是否存在 $PMDOWNDIR/$bxip 目录..." >> $SCRIPTDIR/pm_get.log
    if [ -d $PMDOWNDIR/$bxip ]
    then
        echo "$PMDOWNDIR/$bxip 目录存在,检测该目录下是否存在上一个小时的PM数据" >> $SCRIPTDIR/pm_get.log
        cd $PMDOWNDIR/$bxip
        ls *$LASTHOUR*.gz > $SCRIPTDIR/${bxip}_local_file.txt  2>/dev/null
        if [ -s $SCRIPTDIR/${bxip}_local_file.txt ]
        then
            echo "本时段已经下载过前一个小时的PM数据,现在登录北向服务器$bxip,列出服务器上前一个小时的文件列表,并与本地文件对比，下载新增文件" >> $SCRIPTDIR/pm_get.log
            ftp_file_list
            for mfile in `cat $SCRIPTDIR/ftp_file_list.txt`
            do
                ls $PMDOWNDIR/$bxip/$mfile 1>/dev/null 2>>$SCRIPTDIR/pm_get.log || ftp_file_down_single $mfile
            done
            rm -rf $SCRIPTDIR/ftp_file_list.txt
        else
            echo "本时段还没有下载过前一个小时的PM数据，现在登录北向服务器$bxip,下载前一个小时的PM数据" >> $SCRIPTDIR/pm_get.log
            ftp_file_down_all
        fi
        rm -rf $SCRIPTDIR/${bxip}_local_file.txt
    else
        echo "$PMDOWNDIR/$bxip 目录不存在,创建目录并下载前一个小时的PM数据" >> $SCRIPTDIR/pm_get.log
        mkdir -p $PMDOWNDIR/$bxip
        ftp_file_down_all
    fi
    ;;

    SFTP|sftp)
    echo "北向服务器 $bxip 登录方式是SFTP,检测本地是否存在 $PMDOWNDIR/$bxip 目录..." >> $SCRIPTDIR/pm_get.log
    if [ -d $PMDOWNDIR/$bxip ]
    then
        echo "$PMDOWNDIR/$bxip 目录存在,检测该目录下是否存在上一个小时的PM数据" >> $SCRIPTDIR/pm_get.log
        cd $PMDOWNDIR/$bxip
        ls *$LASTHOUR*.gz > $SCRIPTDIR/${bxip}_local_file.txt  2>/dev/null
        if [ -s $SCRIPTDIR/${bxip}_local_file.txt ]
        then
            echo "本时段已经下载过前一个小时的PM数据,现在登录北向服务器$bxip,列出服务器上前一个小时的文件列表,并与本地文件对比，下载新增文件" >> $SCRIPTDIR/pm_get.log
            ssh_file_list
            for mfile in `cat $SCRIPTDIR/ssh_file_list.txt`
            do
                bxfile=`echo $mfile | xargs basename`
                ls $PMDOWNDIR/$bxip/$bxfile 1>/dev/null 2>>$SCRIPTDIR/pm_get.log || ssh_file_down_single $bxfile
            done
            rm -rf $SCRIPTDIR/ssh_file_list.txt
        else
            echo "本时段还没有下载过前一个小时的PM数据，现在登录北向服务器$bxip,下载前一个小时的PM数据" >> $SCRIPTDIR/pm_get.log
            ssh_file_down_all
        fi
        rm -rf $SCRIPTDIR/${bxip}_local_file.txt
    else
        echo "$PMDOWNDIR/$bxip 目录不存在,创建目录并下载前一个小时的PM数据" >> $SCRIPTDIR/pm_get.log
        mkdir -p $PMDOWNDIR/$bxip
        ssh_file_down_all
    fi
    ;;

    *)
    echo "北向服务器 $bxip 登录方式非法,请检查数据库配置" >> $SCRIPTDIR/pm_get.log
    ;;

    esac
done
#sed -i '/^\s*$/d' $SCRIPTDIR/ssh_file_list.txt
rm -rf $SCRIPTDIR/bxlist.txt
echo "=======================================================================" >> $SCRIPTDIR/pm_get.log
echo "程序结束 <-------------------> 开始执行时间: `date`"                      >> $SCRIPTDIR/pm_get.log
echo "=======================================================================" >> $SCRIPTDIR/pm_get.log
