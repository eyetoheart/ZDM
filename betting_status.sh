#!/bin/sh
###############################################
## file name : betting_status.sh
## creator:zhangdm
## create time:2019-07-08
## modify time:
## copyright (C) BeiJing IWT Technology Ltd.
###############################################

###################Define Envionment Variables########
SCRIPTDIR="/home/postgres/backup/script/betting_status"
ANHOURAGO="`date -d '-3 minute' "+%Y-%m-%d %H:%M:%S"`"
ANHOURAGO25="`date -d '-1443 minute' "+%Y-%m-%d %H:%M:%S"`"

LANG=zh_CN.GB2312
export LANG

#DBSERVERSITE="192.168.80.54"
#DBSERVERPORT="5434"
#DBSERVERUSER="postgres"
#DBSERVERDBNAME="lottomagic_test"		## 数据库的名字

DBSERVERSITE="192.168.108.27"
DBSERVERPORT="5432"
DBSERVERUSER="postgres"
DBSERVERDBNAME="lottomagic"

echo "######################################################check betting statistic,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`##########################" >> $SCRIPTDIR/logs.txt
STATUS_NUMBER="`/opt/db/pgsql9/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(iwoid) from channel_order_t where accept_time<'$ANHOURAGO' and accept_time>'$ANHOURAGO25' and status= 1;" | awk 'NR == 3 {print $1}'`"
#STATUS_NUMBER=1
########################################发送邮件函数#####################################
sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%Y-%m-%d %H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    echo -e "From $ANHOURAGO25 To $ANHOURAGO\n[ERROR]彩运无限系统投注状态长时间未确定的渠道商订单:"$STATUS_NUMBER | mutt -s "`echo "[ERROR]彩运无限系统投注状态长时间未确定的渠道商订单:"$STATUS_NUMBER`" $user -F ~/.muttrc2
done
}

#####################################################判断#############################
if [ $STATUS_NUMBER -eq 0 ]
then
    echo "from $ANHOURAGO25 to $ANHOURAGO lottomagic system betting status OK,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
else
    echo "from $ANHOURAGO25 to $ANHOURAGO lottomagic system betting status Fail,Now start send mail,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    sendmailtouser

fi
