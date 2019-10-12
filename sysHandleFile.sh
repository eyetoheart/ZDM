#!/bin/sh

SCRIPTDIR="/home/iwgroup/backup/script/sysHandleFile"
BAKDIR="/home/iwgroup/backup/script/sysHandleFile/mailbak"
DATEDAY="`date -d '-0 day' "+%Y_%m_%d"`"

APPSERVERSITE="192.168.108.25"
APPSERVERUSER="iwgroup"
APPSERVERPASS='password'    #
APPSERVERPATH="/opt/iwgroup/vasoss4.3/lottomagic/pro/sysHandleFile"
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
#   echo "没有生成 $DATEDAY_彩运无限自行处理彩票明细.xls 文件" | mutt -s "没有生成 $DATEDAY_彩运无限自行处理彩票明细.xls 文件" yangf@iwgroup.com.cn,rmt@iwgroup.com.cn
fi





系统处理彩票数据邮件通知

receiver.txt文件内容：
janelle@iwgroup.com.cn,caozhe
zhaoll@iwgroup.com.cn,zhaolinlin
luxm@iwgroup.com.cn,luxueming
yangf@iwgroup.com.cn,yangfan
13552961152@139.com,yangfan
rmt@iwgroup.com.cn,yunweibu
