#!/bin/sh

SCRIPTDIR="/home/iwgroup/backup/script/check_upfile_state"
YESTERDAY="`date -d '-1 day' "+%Y%m%d"`"
LOCALFILE="trans-data-${YESTERDAY}.txt"

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
    echo $1 | mutt -s "彩运无限系统对账文件生成或上传有故障:$YESTERDAY" $user
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
    FTPPATH="transdata"
    
    LOCALFILEPATH="/home/iwgroup/backup/script/data_from_108.25nfs/channelOrderSettleFile/settleFile/$FTPNAME"

    if [ -f $LOCALFILEPATH/$LOCALFILE ]
    then
        LOCALFILESIZE="`ls -l $LOCALFILEPATH/$LOCALFILE | awk  '{print $5}'`"
        ftpfile
        grep $LOCALFILE  $SCRIPTDIR/tempfile.log  >> $SCRIPTDIR/logs.txt 2>&1
        if [ $? -ne 0 ]
        then
            mailcontent="昨天没有将本地的$LOCALFILE文件上传给商户$FTPNAME的FTP服务器,请检查"
            sendmailtouser $mailcontent
        else
            RFILESIZE="`grep $LOCALFILE $SCRIPTDIR/tempfile.log | awk '{print $5}'`"
            if [ $LOCALFILESIZE -ne $RFILESIZE ]
            then
                mailcontent="上传给商户$FTPNAME的对账文件与本地文件大小不一致，请检查"
                sendmailtouser $mailcontent
            fi
        fi
    else
        mailcontent="昨天本地服务器没有生成商户$FTPNAME的对账文件，请检查"
        sendmailtouser $mailcontent
    fi
done

rm -rf $SCRIPTDIR/ftptask.txt
rm -rf $SCRIPTDIR/tempfile.log





该脚本的配置文件的名字是：config.txt，内容如下：
商户代码,FTP服务器,FTP登录账号,FTP端口,模式,FTP密码
C10000,116.228.224.195,ftpuser,21,passive,ftppasswd
C21000,47.95.197.220,ftpuser,21,passive,ftppasswd
C20000,47.98.112.62,ftpuser,52121,,ftppasswd
c23000,47.100.6.77,ftpuser,21,passive,ftppasswd
