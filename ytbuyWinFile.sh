#!/bin/sh

SCRIPTDIR="/home/iwgroup/backup/script/ytbuyWinFile"
BAKDIR="/home/iwgroup/backup/script/ytbuyWinFile/mailbak"
DATEDAY="`date -d '-1 day' "+%Y_%m_%d"`"

APPSERVERSITE="192.168.108.25"
APPSERVERUSER="iwgroup"
APPSERVERPASS='password'    #
APPSERVERPATH="/opt/iwgroup/vasoss4.3/lottomagic/pro/ytbuyWinFile"
APPSERVERFILE="${DATEDAY}_英泰伟业支付买单彩票中奖情况.xls"

downfile () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVERSITE:${APPSERVERPATH}/$APPSERVERFILE  $BAKDIR >> $SCRIPTDIR/logs.log 2>&1

}

sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    echo "英泰伟业支付买单彩票中奖情况:$DATEDAY" | mutt -s "英泰伟业支付买单彩票中奖情况:$DATEDAY" $user -a $BAKDIR/$APPSERVERFILE
done
}

echo "-----------------------------------`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`----------------" >> $SCRIPTDIR/logs.log

downfile

if [ -f $BAKDIR/$APPSERVERFILE ]
then
    sendmailtouser
else
    echo "没有生成 $APPSERVERFILE 文件" >> $SCRIPTDIR/logs.log
#   echo "没有生成 $APPSERVERFILE 文件" | mutt -s "没有生成 $APPSERVERFILE 文件" zhangdm@iwgroup.com.cn
fi




receiver.txt文件内容：
janelle@iwgroup.com.cn,caozhe
zhaoll@iwgroup.com.cn,zhaolinlin
luxm@iwgroup.com.cn,luxueming
yangf@iwgroup.com.cn,yangfan
13552961152@139.com,yangfan
13661089847@139.com,zhangdm
rmt@iwgroup.com.cn,yunweibu
