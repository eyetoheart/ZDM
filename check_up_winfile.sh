#!/bin/sh

SCRIPTDIR="/home/postgres/backup/script/check_up_winfile"
YESTERDAY="`date -d '-0 day' "+%Y%m%d"`"
source ~/.bash_profile

DBSERVER="192.168.108.27"
DBSERVERPORT="5432"
DBSERVERUSER="postgres"
DBSERVERDBNAME="lottomagic"


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
    echo $1 | mutt -s "彩运无限系统中奖文件生成或上传有故障:$YESTERDAY" $user
done
}

echo "-------------------`date -d '-0 day' "+%Y-%m-%d %H:%M:%S"`-----------------------" >> $SCRIPTDIR/logs.txt

/usr/local/pgsql/bin/psql -h $DBSERVER -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select game_id, issue_number from lottery_issue_t where end_time>'${YESTERDAY} 00:00:00' and end_time < '${YESTERDAY} 23:59:59'" | sed '$d' | sed '$d' | sed '1,2d' | sed 's/\ //g' | sed 's/|/,/g' > $SCRIPTDIR/issue.txt

if [ -s $SCRIPTDIR/issue.txt ]
then
    echo "win_prize file OK" >> $SCRIPTDIR/logs.txt

    for  i  in  `cat $SCRIPTDIR/config.txt`
    do

        FTPNAME="`echo $i | awk -F, '{print $1}'`"
        FTPSERVER="`echo $i | awk -F, '{print $2}'`"
        FTPUSER="`echo $i | awk -F, '{print $3}'`"
        FTPPORT="`echo $i | awk -F, '{print $4}'`"
        FTPMODE="`echo $i | awk -F, '{print $5}'`"
        FTPPASS="`echo $i | awk -F, '{print $6}'`"
        FTPPATH="winprize"
    
        LOCALFILEPATH="/home/postgres/backup/script/data_from_108.25nfs/winPrizeFile/file/$FTPNAME"
        for win in `cat $SCRIPTDIR/issue.txt`
        do
            gamename="`echo $win | awk -F, '{print $1}'`"
            gameissue="`echo $win | awk -F, '{print $2}'`"
            LOCALFILE="win_prize_${gamename}_${gameissue}.txt"
            if [ -f $LOCALFILEPATH/$LOCALFILE ]
            then
                LOCALFILESIZE="`ls -l $LOCALFILEPATH/$LOCALFILE | awk  '{print $5}'`"
                ftpfile
                grep $LOCALFILE  $SCRIPTDIR/tempfile.log  >> $SCRIPTDIR/logs.txt 2>&1
                if [ $? -ne 0 ]
                then
                    mailcontent="今天没有将本地的$LOCALFILE文件上传给商户$FTPNAME的FTP服务器,请检查"
                    sendmailtouser $mailcontent
                else
                    RFILESIZE="`grep $LOCALFILE $SCRIPTDIR/tempfile.log | awk '{print $5}'`"
                    if [ $LOCALFILESIZE -ne $RFILESIZE ]
                    then
                        mailcontent="上传给商户$FTPNAME的中奖文件与本地文件大小不一致，请检查"
                        sendmailtouser $mailcontent
                    fi
                fi
            else
                mailcontent="今天本地服务器没有生成商户$FTPNAME的中奖文件，请检查"
                sendmailtouser $mailcontent
            fi
        done
    done
fi

rm -rf $SCRIPTDIR/ftptask.txt
rm -rf $SCRIPTDIR/tempfile.log
rm -rf $SCRIPTDIR/issue.txt




该脚本的配置文件的名字是：config.txt，内容如下：
商户代码,FTP服务器,FTP登录账号,FTP端口,模式,FTP密码
C10000,116.228.224.195,ftpuser,21,passive,ftppasswd
C21000,47.95.197.220,ftpuser,21,passive,ftppasswd
C20000,47.98.112.62,ftpuser,52121,,ftppasswd
c23000,47.100.6.77,ftpuser,21,passive,ftppasswd