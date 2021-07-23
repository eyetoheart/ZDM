#!/bin/sh

SCRIPTDIR="/home/postgres/backup/script/check_up_winfile"
YESTERDAY="`date -d '-0 day' "+%Y-%m-%d"`"
source ~/.bash_profile

FLAGDATE="81900"
FILEDATE="82800"
CURRENT_HOUR="`date +"%H"`"
CURRENT_MINUTE="`date +"%M"`"
CURRENT_SECOND="`date +"%S"`"
CURRENT_SECOND="`expr $CURRENT_HOUR \* 3600 + $CURRENT_MINUTE \* 60 + $CURRENT_SECOND`"

DBSERVER="192.168.108.27"
DBSERVERPORT="5432"
DBSERVERUSER="postgres"
DBSERVERDBNAME="lottomagic"
DBSERVERPATH="winprize"

ftpfile () {
echo "open $FTPSERVER $FTPPORT" > $SCRIPTDIR/ftptask.txt
echo "user $FTPUSER $FTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "$FTPMODE" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "cd $DBSERVERPATH" >> $SCRIPTDIR/ftptask.txt
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
    echo "winPrize issue file OK" >> $SCRIPTDIR/logs.txt

    for  i  in  `cat $SCRIPTDIR/config.txt`
    do

        FTPNAME="`echo $i | awk -F, '{print $1}'`"
        FTPSERVER="`echo $i | awk -F, '{print $2}'`"
        FTPUSER="`echo $i | awk -F, '{print $3}'`"
        FTPPORT="`echo $i | awk -F, '{print $4}'`"
        FTPMODE="`echo $i | awk -F, '{print $5}'`"
        FTPPASS="`echo $i | awk -F, '{print $6}'`"
        FTPALIASES="`echo $i | awk -F, '{print $7}'`"
    
        LOCALFILEPATH="/home/postgres/backup/script/data_from_108.25nfs/winPrizeFile/file/$FTPNAME"
        LOCALFLAGPATH="/home/postgres/backup/script/data_from_108.25nfs/winPrizeFile/flag/$FTPNAME"
        for win in `cat $SCRIPTDIR/issue.txt`
        do
            gamename="`echo $win | awk -F, '{print $1}'`"
            gameissue="`echo $win | awk -F, '{print $2}'`"
            LOCALFILE="win_prize_${gamename}_${gameissue}.txt"
            LOCALFLAG="win_prize_${gamename}_${gameissue}_flag.txt"

            if [[ $CURRENT_SECOND -ge $FLAGDATE && $CURRENT_SECOND -lt $FILEDATE ]]
            then
                if [ -s $LOCALFLAGPATH/$LOCALFLAG ]
                then
                    flagcontent="`cat $LOCALFLAGPATH/$LOCALFLAG`"
                    if [ $flagcontent != "ok" ]
                    then
                        mailcontent="$FTPNAME-$FTPALIASES,中奖标志文件生成有问题,内容不是ok"
                        sendmailtouser $mailcontent
                    fi
                else
                    mailcontent="$FTPNAME-$FTPALIASES,中奖标志文没有生成,或者生成有问题,内容为空"
                    sendmailtouser $mailcontent
                fi
                if [ ! -f $LOCALFILEPATH/$LOCALFILE ]
                then
                    mailcontent="$FTPNAME-$FTPALIASES,中奖文件没有生成"
                    sendmailtouser $mailcontent
                fi
            fi
            if [ $CURRENT_SECOND -ge $FILEDATE ]
            then
                if [ -f $LOCALFILEPATH/$LOCALFILE ]
                then
                    LOCALFILESIZE="`ls -l $LOCALFILEPATH/$LOCALFILE | awk  '{print $5}'`"
                    ftpfile
                    grep $LOCALFILE  $SCRIPTDIR/tempfile.log  >> $SCRIPTDIR/logs.txt 2>&1
                    if [ $? -ne 0 ]
                    then
                        mailcontent="今天没有将本地的$LOCALFILE文件上传给商户$FTPNAME-$FTPALIASES的FTP服务器,请检查"
                        sendmailtouser $mailcontent
                    else
                        RFILESIZE="`grep $LOCALFILE $SCRIPTDIR/tempfile.log | awk '{print $5}'`"
                        if [ $LOCALFILESIZE -ne $RFILESIZE ]
                        then
                            mailcontent="上传给商户$FTPNAME-$FTPALIASES的中奖文件与本地文件大小不一致，请检查"
                            sendmailtouser $mailcontent
                        fi
                    fi
                fi
            fi
        done
    done
fi

rm -rf $SCRIPTDIR/ftptask.txt
rm -rf $SCRIPTDIR/tempfile.log
rm -rf $SCRIPTDIR/issue.txt













config.txt配置文件内容：
C10000,116.228.224.195,gctrpiwtftp,21,passive,ftppassword,guocaitong
C21000,47.95.197.220,yingtai,21,passive,ftppassword,huijinkeji
c23000,47.100.6.77,iwgroup,21,passive,ftppassword,zhuowangxinxi
C25000,47.95.197.220,yingtaisv2,21,passive,ftppassword,huijinkeji2





receiver.txt文件内容：
rmt@iwgoup.com.cn,zhangdaoming
13661089847@139.com,zdm
