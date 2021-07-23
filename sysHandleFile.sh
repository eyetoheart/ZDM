#!/bin/sh

SCRIPTDIR="/home/iwgoup/backup/script/sysHandleFile"
BAKDIR="/home/iwgoup/backup/script/sysHandleFile/mailbak"
DATEDAY="`date -d '-0 day' "+%Y_%m_%d"`"

APPSERVERSITE="192.168.108.25"
APPSERVERUSER="iwgoup"
APPSERVERPASS='password'    #
APPSERVERPATH="/opt/iwgoup/vasoss4.3/lottomagic/pro/sysHandleFile"
APPSERVERFILE="${DATEDAY}_彩运无限自行处理彩票明细.xls"

downfile () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVERSITE:${APPSERVERPATH}/$APPSERVERFILE  $BAKDIR >> $SCRIPTDIR/logs.log 2>&1

}

sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    echo "彩运无限自行处理彩票明细:$DATEDAY" | mutt -s "彩运无限自行处理彩票明细:$DATEDAY" $user -a $BAKDIR/$APPSERVERFILE
done
}

if [ -f $BAKDIR/$APPSERVERFILE ]
then
    sendmailtouser
else
    echo "没有生成 $DATEDAY_彩运无限自行处理彩票明细.xls 文件,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
#   echo "没有生成 $DATEDAY_彩运无限自行处理彩票明细.xls 文件" | mutt -s "没有生成 $DATEDAY_彩运无限自行处理彩票明细.xls 文件" yangf@iwgoup.com.cn,rmt@iwgoup.com.cn
fi





系统处理彩票数据邮件通知

receiver.txt文件内容：
rmt@iwgoup.com.cn,yunweibu
