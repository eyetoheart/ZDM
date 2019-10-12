#!/bin/sh
###############################################
## file name : ytbetstat.sh
## creator:zhangdm
## create time:2019-08-18
## modify time:
## copyright (C) BeiJing IWT Technology Ltd.
###############################################

###################Define Envionment Variables########
SCRIPTDIR="/home/postgres/backup/script/ytbetstat"
ANHOURAGO="`date -d '-0 day' "+%Y-%m-%d"` 00:00:00"
ANHOURAGO25="`date -d '-1 day' "+%Y-%m-%d"` 00:00:00"
ANHOURAGO26="`date -d '-1 day' "+%Y-%m-%d"`"

LANG=zh_CN.GBK
export LANG

#DBSERVERSITE="192.168.80.54"
#DBSERVERPORT="5434"
#DBSERVERUSER="postgres"
#DBSERVERDBNAME="lottomagic_test"		## 数据库的名字

DBSERVERSITE="192.168.108.27"
DBSERVERPORT="5432"
DBSERVERUSER="postgres"
DBSERVERDBNAME="lottomagic"

########################################发送邮件函数#####################################
sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%Y-%m-%d %H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    echo -e "[ERROR]彩运无限系统英泰买单的投注数据报表统计不正常:"$STATUS_NUMBER2 | mutt -s "`echo "[ERROR]彩运无限系统英泰买单的投注数据报表统计不正常:"$STATUS_NUMBER2`" $user -F ~/.muttrc2
done
}

#####################################################判断#############################

echo "######################################################check betting statistic,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`##########################" >> $SCRIPTDIR/logs.txt
STATUS_NUMBER1="`/opt/db/pgsql9/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(iwoid) from bet_detail_t  where ticket_time>='$ANHOURAGO25' and ticket_time<'$ANHOURAGO' and sys_handle_status = 1;" | awk 'NR == 3 {print $1}'`"

if [ $STATUS_NUMBER1 -ne 0 ]
then
    STATUS_NUMBER2="`/opt/db/pgsql9/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(iwoid) from yt_bet_data_stat_day_t  where stat_date='$ANHOURAGO26';" | awk 'NR == 3 {print $1}'`"
    if [ $STATUS_NUMBER2 -eq 0 ]
    then
        sendmailtouser
    fi
fi





英泰买单投注数据统计监控

配置文件内容：
yangf@iwgroup.com.cn,yangfan
13552961152@139.com,yangfan
rmt@iwgroup.com.cn,yunweibu
13661089847@139.com,zhangdaoming
