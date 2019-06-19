#!/bin/sh
###############################################
## file name : point_calculate_statcheck.sh
## creator:zhangdm
## create time:2010-03-10
## modify time:2010-03-10
## copyright (C) BeiJing IWT Technology Ltd.
###############################################

###################Define Envionment Variables########
SCRIPTDIR="/home/postgres/backup/script/point_calculate_statcheck"
#YESTERDAY="`date --date="yesterday" "+%Y-%m-%d"`"
YESTERDAY="`date -d '-1 day' "+%Y-%m-%d"`"

LANG=zh_CN.GB2312
export LANG

#JIFENSERVER="192.168.61.2"
#JIFENPASS='123456a'
#JIFENPASS='qX9&L1$l'
JIFENSERVER="192.168.60.11"
JIFENUSER="iwgroup"
JIFENPASS='x*5R3)Gq'
JIFENPATH="/opt/iwgroup/vasoss/point-calculate-server/config"

DBSERVERSITE="192.168.60.20"
DBSERVERPORT="5432"
DBSERVERUSER="postgres"
DBSERVERPASS='iwgroupytwy'
DBSERVERDBNAME="pointdb"		## 数据库的名字

echo "######################################################check point calculate statistic,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`##########################" >> $SCRIPTDIR/logs.txt
#######################获取昨天开奖的期号文件，并存储在本地的临时文件temp.txt内#########################
/usr/bin/plink -l $JIFENUSER -pw $JIFENPASS $JIFENUSER@$JIFENSERVER grep $YESTERDAY $JIFENPATH/point-issue-file.txt > $SCRIPTDIR/temp.txt

#######################理论上，昨天全国玩法积分数据文件个数############################
THEORETICALLY_NATIONWIDE_NUMBER="`awk -F, '$2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"

#######################理论上，昨天省级玩法积分数据文件个数#############################
#THEORETICALLY_PROVINCE_NUMBER="`awk -F, '$2 !~ /10001|10002|10003/ && $1 !~ /33|36/' $SCRIPTDIR/temp.txt | wc -l`"
#THEORETICALLY_PROVINCE_NUMBER="`awk -F, '$2 !~ /10001|10002|10003/ && $1 !~ /33|36|41/' $SCRIPTDIR/temp.txt | wc -l`"
THEORETICALLY_PROVINCE_NUMBER="`awk -F, '$2 !~ /10001|10002|10003/ && $1 !~ /33|36|41|45/' $SCRIPTDIR/temp.txt | wc -l`"

#######################理论上，昨天全国玩法做省积分计算的文件个数#######################
#THEORETICALLY_AGAIN_NATIONWIDE_NUMBER="`awk -F, '/^14|^41|^45|^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"
#THEORETICALLY_AGAIN_NATIONWIDE_NUMBER="`awk -F, '/^45|^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"
THEORETICALLY_AGAIN_NATIONWIDE_NUMBER="`awk -F, '/^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"
#THEORETICALLY_AGAIN_NATIONWIDE_NUMBER_temp="`awk -F, '/^14|^45|^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"

#######################理论上，昨天做省级积分计算的所有积分数据文件个数###########################
THEORETICALLY_PROVINCE_ALL_NUMBER="`/usr/bin/expr $THEORETICALLY_PROVINCE_NUMBER + $THEORETICALLY_AGAIN_NATIONWIDE_NUMBER`"

#######################理论上，昨天做积分计算的所有玩法的数据文件个数######################
THEORETICALLY_ALL_POINT_NUMBER="`/usr/bin/expr $THEORETICALLY_NATIONWIDE_NUMBER + $THEORETICALLY_PROVINCE_ALL_NUMBER`"

#######################实际上，昨天做全国积分计算的有效积分数据文件个数########################
ACTUALLY_NATIONWIDE_ALL_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status = '2' and point_type = '0';" | awk 'NR == 3 {print $1}'`"
ACTUALLY_NATIONWIDE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and point_type = '0';" | awk 'NR == 3 {print $1}'`"
ACTUALLY_NATIONWIDE_UNEFFECTIVE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status != '2' and point_type = '0';" | awk 'NR == 3 {print $1}'`"    ######昨天全国积分计算handle_status状态不等于2的记录数

#######################实际上，昨天做省级积分计算的有效积分数据文件个数########################
ACTUALLY_PROVINCE_ALL_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status = '2' and point_type = '1';" | awk 'NR == 3 {print $1}'`"

#######################实际上,昨天做省级计分计算的所有文件数量#############################
ACTUALLY_PROVINCE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and point_type = '1';" | awk 'NR == 3 {print $1}'`"
ACTUALLY_PROVINCE_UNEFFECTIVE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status != '2' and point_type = '1';" | awk 'NR == 3 {print $1}'`"    ####昨天省积分计算handle_status状态不等于2的记录数

#######################实际上，昨天做积分计算的所有玩法的数据文件个数######################
ACTUALLY_ALL_POINT_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date;" | awk 'NR == 3 {print $1}'`"

######################实际上，昨天做积分计算的所有玩法的有效数据文件个数###################
ACTUALLY_ALL_POINT_EFFECTIVE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status = '2';" | awk 'NR == 3 {print $1}'`"

echo "理论上, '$YESTERDAY' 日做积分计算的所有玩法的数据文件个数是:$THEORETICALLY_ALL_POINT_NUMBER" >> $SCRIPTDIR/logs.txt
echo "实际上, '$YESTERDAY' 日做积分计算的所有玩法的数据文件个数是:$ACTUALLY_ALL_POINT_NUMBER" >> $SCRIPTDIR/logs.txt
echo "实际上, '$YESTERDAY' 日做积分计算的所有玩法的有效数据文件个数是:$ACTUALLY_ALL_POINT_EFFECTIVE_NUMBER" >> $SCRIPTDIR/logs.txt
echo >> $SCRIPTDIR/logs.txt
echo "理论上, '$YESTERDAY' 日做全国积分计算的积分数据文件个数是:$THEORETICALLY_NATIONWIDE_NUMBER" >> $SCRIPTDIR/logs.txt
echo "实际上, '$YESTERDAY' 日做全国积分计算的有效积分数据文件个数是:$ACTUALLY_NATIONWIDE_ALL_NUMBER" >> $SCRIPTDIR/logs.txt
echo >> $SCRIPTDIR/logs.txt
echo "理论上, '$YESTERDAY' 日做省级积分计算的积分数据文件个数是:$THEORETICALLY_PROVINCE_ALL_NUMBER" >> $SCRIPTDIR/logs.txt
echo "实际上, '$YESTERDAY' 日做省级积分计算的有效积分数据文件个数是:$ACTUALLY_PROVINCE_ALL_NUMBER" >> $SCRIPTDIR/logs.txt
echo >> $SCRIPTDIR/logs.txt
########################################发送邮件函数#####################################
sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    awk 'NR == '$1'' $SCRIPTDIR/word.txt | mutt -s "`awk 'NR == 1' $SCRIPTDIR/word.txt`$YESTERDAY" $user -F ~/.muttrc2
done
}

#####################################################判断#############################
if [ $THEORETICALLY_ALL_POINT_NUMBER -eq $ACTUALLY_ALL_POINT_EFFECTIVE_NUMBER ]
then
    echo "point calculate OK,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt

elif [[ $ACTUALLY_ALL_POINT_NUMBER -eq $ACTUALLY_ALL_POINT_EFFECTIVE_NUMBER && $ACTUALLY_ALL_POINT_NUMBER -ne 0 ]]
then
    echo "`awk 'NR == 2' $SCRIPTDIR/word.txt`" >> $SCRIPTDIR/logs.txt
    sendmailtouser 2

elif [[ $ACTUALLY_ALL_POINT_NUMBER -eq $ACTUALLY_ALL_POINT_EFFECTIVE_NUMBER && $ACTUALLY_ALL_POINT_NUMBER -eq 0 ]]
then
    echo "`awk 'NR == 3' $SCRIPTDIR/word.txt`" >> $SCRIPTDIR/logs.txt
    sendmailtouser 3

elif [[ $ACTUALLY_NATIONWIDE_UNEFFECTIVE_NUMBER -ne 0 && $ACTUALLY_PROVINCE_UNEFFECTIVE_NUMBER -eq 0 ]]
then
    echo "`awk 'NR == 4' $SCRIPTDIR/word.txt`" >> $SCRIPTDIR/logs.txt
    sendmailtouser 4

elif [[ $ACTUALLY_PROVINCE_UNEFFECTIVE_NUMBER -ne 0 && $ACTUALLY_NATIONWIDE_UNEFFECTIVE_NUMBER -eq 0 ]]
then
    echo "`awk 'NR == 5' $SCRIPTDIR/word.txt`" >> $SCRIPTDIR/logs.txt
    sendmailtouser 5

elif [[ $ACTUALLY_PROVINCE_UNEFFECTIVE_NUMBER -ne 0 && $ACTUALLY_NATIONWIDE_UNEFFECTIVE_NUMBER -ne 0 ]]
then
    echo "`awk 'NR == 6' $SCRIPTDIR/word.txt`" >> $SCRIPTDIR/logs.txt
    sendmailtouser 6

else
    echo "ERROR" >> $SCRIPTDIR/logs.txt

fi
rm -rf $SCRIPTDIR/temp.txt
