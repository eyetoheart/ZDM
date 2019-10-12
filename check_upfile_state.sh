#!/bin/sh

SCRIPTDIR="/home/iwgroup/backup/script/check_upfile_state"
YESTERDAY="`date -d '-1 day' "+%Y%m%d"`"
FLAGDATE="6600"
FILEDATE="7800"
CURRENT_HOUR="`date +"%H"`"
CURRENT_MINUTE="`date +"%M"`"
CURRENT_SECOND="`date +"%S"`"
CURRENT_SECOND="`expr $CURRENT_HOUR \* 3600 + $CURRENT_MINUTE \* 60 + $CURRENT_SECOND`"
LOCALFILE="trans-data-${YESTERDAY}.txt"
LOCALFLAG="flag-${YESTERDAY}.txt"
source ~/.bash_profile

ftpfile () {
echo "open $FTPSERVER $FTPPORT" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "$FTPMODE" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $FTPPATH" >> $SCRIPTDIR/ftptask.txt
echo "ls $LOCALFILE" >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
/usr/bin/ftp -vin < $SCRIPTDIR/ftptask.txt > $SCRIPTDIR/tempfile.log 2>&1

}

sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    echo $1 | mutt -s "彩运无限系统对账文件或标志文件生成或上传有故障:$YESTERDAY" $user
done
}

echo "---------------------`date -d '-0 day' "+%Y-%m-%d %H:%M:%S"`----------------------------" >> $SCRIPTDIR/logs.txt

for  i  in  `cat $SCRIPTDIR/config.txt`
do

    FTPNAME="`echo $i | awk -F, '{print $1}'`"
    FTPSERVER="`echo $i | awk -F, '{print $2}'`"
    FTPUSER="`echo $i | awk -F, '{print $3}'`"
    FTPPORT="`echo $i | awk -F, '{print $4}'`"
    FTPMODE="`echo $i | awk -F, '{print $5}'`"
    FTPPASS="`echo $i | awk -F, '{print $6}'`"
    FTPALIASES="`echo $i | awk -F, '{print $7}'`"
    FTPPATH="transdata"
    
    LOCALFLAGPATH="/home/iwgroup/backup/script/data_from_108.25nfs/channelOrderSettleFile/flag/$FTPNAME"
    LOCALFILEPATH="/home/iwgroup/backup/script/data_from_108.25nfs/channelOrderSettleFile/settleFile/$FTPNAME"

    if [[ $CURRENT_SECOND -ge $FLAGDATE && $CURRENT_SECOND -lt $FILEDATE ]]
    then
        if [ -s $LOCALFLAGPATH/$LOCALFLAG ]
        then
            flagcontent="`cat $LOCALFLAGPATH/$LOCALFLAG`"
            if [ $flagcontent != "ok" ]
            then
                mailcontent="$FTPNAME-$FTPALIASES,对账标志文件生成有问题,内容不是ok"
                sendmailtouser $mailcontent
            fi
        else
            mailcontent="$FTPNAME-$FTPALIASES,对账标志文件没有生成,或者生成有问题,内容为空"
            sendmailtouser $mailcontent
        fi

        if [ ! -f $LOCALFILEPATH/$LOCALFILE ]
        then
            mailcontent="昨天本地服务器没有生成商户$FTPNAME-$FTPALIASES的对账文件，请检查"
            sendmailtouser $mailcontent
        fi
    fi
    if [ $CURRENT_SECOND -gt $FILEDATE ]
    then

        if [ -f $LOCALFILEPATH/$LOCALFILE ]
        then
            LOCALFILESIZE="`ls -l $LOCALFILEPATH/$LOCALFILE | awk  '{print $5}'`"
            ftpfile
            grep $LOCALFILE  $SCRIPTDIR/tempfile.log  >> $SCRIPTDIR/logs.txt 2>&1
            if [ $? -ne 0 ]
            then
                mailcontent="昨天没有将本地的$LOCALFILE文件上传给商户$FTPNAME-$FTPALIASES的FTP服务器,请检查"
                sendmailtouser $mailcontent
            else
                RFILESIZE="`grep $LOCALFILE $SCRIPTDIR/tempfile.log | awk '{print $5}'`"
                if [ $LOCALFILESIZE -ne $RFILESIZE ]
                then
                    mailcontent="上传给商户$FTPNAME-$FTPALIASES的对账文件与本地文件大小不一致，请检查"
                    sendmailtouser $mailcontent
                fi
            fi
        fi
    fi
done

rm -rf $SCRIPTDIR/ftptask.txt
rm -rf $SCRIPTDIR/tempfile.log











该脚本文件的配置文件：
C10000,116.228.224.195,gctrpiwtftp,21,passive,ftppassword,guocaitong
C21000,47.95.197.220,yingtai,21,passive,ftppassword,huijinkeji
c23000,47.100.6.77,iwgroup,21,passive,ftppassword,zhuowangxinxi
C25000,47.95.197.220,yingtaisv2,21,passive,ftppassword,huijinkeji2


receiver.txt文件内容：
rmt@iwgroup.com.cn,yunweibu
yangf@iwgroup.com.cn,yangfan
13552961152@139.com,yangfan
13661089847@139.com,zhangdm
