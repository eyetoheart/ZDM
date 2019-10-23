#!/bin/sh
###############################################
## file name : channel_unorder.sh
## creator:zhangdm
## create time:2019-10-21
## modify time:2019-10-21
## copyright (C) BeiJing IWT Technology Ltd.
###############################################

###################Define Envionment Variables########
SCRIPTDIR="/home/postgres/backup/script/channel_unorder"
ANHOURAGO="`date -d '-35 minute' "+%Y-%m-%d %H:%M:%S"`"
ANHOURAGO25="`date -d '-1475 minute' "+%Y-%m-%d %H:%M:%S"`"
source ~/.bash_profile

DBSERVERSITE="192.168.108.27"
DBSERVERPORT="5432"
DBSERVERUSER="postgres"
DBSERVERDBNAME="lottomagic"

echo "######################################################channel order statistic,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`##########################" >> $SCRIPTDIR/logs.txt
STATUS_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(iwoid) from channel_order_t where accept_time<'${ANHOURAGO}' and accept_time>'${ANHOURAGO25}' and status= 0;" | awk 'NR == 3 {print $1}'`"
#STATUS_NUMBER=5
#############################################################################################
sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%Y-%m-%d %H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    echo -e "From $ANHOURAGO25 To $ANHOURAGO\n[ERROR]彩运无限系统渠道商投注请求后超35分钟未进行投注的订单:"$STATUS_NUMBER | mutt -s "`echo "[ERROR]彩运无限系统渠道商投注请求后超35分钟未进行投注的订单:"$STATUS_NUMBER`" $user
done
}

#############################################################################################
if [ $STATUS_NUMBER -eq 0 ]
then
    echo "from $ANHOURAGO25 to $ANHOURAGO channel order status:$STATUS_NUMBER OK,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
else
    echo "from $ANHOURAGO25 to $ANHOURAGO channel order status:$STATUS_NUMBER Fail,Now start send mail,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    sendmailtouser
fi




配置文件：receiver.txt
rmt@iwgroup.com.cn,zhangdaoming
yangf@iwgroup.com.cn,yangfan
13552961152@139.com,yangfan
