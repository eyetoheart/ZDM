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




道明，你好：
       脚本运行时间和查询参数调整如下：
	功能描述：监控彩运无限系统受理渠道商投注请求后，超过35分钟未进行投注的订单（只查询24小时以内的订单），监控到订单后进行邮件告警。
	脚本运行时间：每5分钟运行一次。彩运无限系统每5分钟运行一次关闭订单的任务，关闭超过30分钟仍未进行投注的订单，脚本在系统任务执行1次后进行检查。
	脚本执行SQL：select count(iwoid) from channel_order_t where accept_time<'TIME1' and accept_time>'TIME2' and status= 0;
	执行SQL说明：TIME1取值为脚本执行的时间减去35分钟，TIME2取值为TIME1的值减去1天，值的内容格式为yyyy-MM-dd hh:mm:ss。假设脚本在2019年10月18日12:00:00执行，TIME1的值应为’2019-10-18 11:25:00’，TIME2的值应为’2019-10-17 11:25:00’
	连接数据库：192.168.108.27:5432:lottomagic
	告警邮件通知人：杨帆（yangf@iwgroup.com.cn、13552961152@139.com）、运维部相关人员。





配置文件：receiver.txt
rmt@iwgroup.com.cn,zhangdaoming
yangf@iwgroup.com.cn,yangfan
13552961152@139.com,yangfan
