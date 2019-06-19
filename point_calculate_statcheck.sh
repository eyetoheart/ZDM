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
DBSERVERDBNAME="pointdb"		## ���ݿ������

echo "######################################################check point calculate statistic,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`##########################" >> $SCRIPTDIR/logs.txt
#######################��ȡ���쿪�����ں��ļ������洢�ڱ��ص���ʱ�ļ�temp.txt��#########################
/usr/bin/plink -l $JIFENUSER -pw $JIFENPASS $JIFENUSER@$JIFENSERVER grep $YESTERDAY $JIFENPATH/point-issue-file.txt > $SCRIPTDIR/temp.txt

#######################�����ϣ�����ȫ���淨���������ļ�����############################
THEORETICALLY_NATIONWIDE_NUMBER="`awk -F, '$2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"

#######################�����ϣ�����ʡ���淨���������ļ�����#############################
#THEORETICALLY_PROVINCE_NUMBER="`awk -F, '$2 !~ /10001|10002|10003/ && $1 !~ /33|36/' $SCRIPTDIR/temp.txt | wc -l`"
#THEORETICALLY_PROVINCE_NUMBER="`awk -F, '$2 !~ /10001|10002|10003/ && $1 !~ /33|36|41/' $SCRIPTDIR/temp.txt | wc -l`"
THEORETICALLY_PROVINCE_NUMBER="`awk -F, '$2 !~ /10001|10002|10003/ && $1 !~ /33|36|41|45/' $SCRIPTDIR/temp.txt | wc -l`"

#######################�����ϣ�����ȫ���淨��ʡ���ּ�����ļ�����#######################
#THEORETICALLY_AGAIN_NATIONWIDE_NUMBER="`awk -F, '/^14|^41|^45|^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"
#THEORETICALLY_AGAIN_NATIONWIDE_NUMBER="`awk -F, '/^45|^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"
THEORETICALLY_AGAIN_NATIONWIDE_NUMBER="`awk -F, '/^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"
#THEORETICALLY_AGAIN_NATIONWIDE_NUMBER_temp="`awk -F, '/^14|^45|^61/ && $2 ~ /10001|10002|10003/' $SCRIPTDIR/temp.txt | wc -l`"

#######################�����ϣ�������ʡ�����ּ�������л��������ļ�����###########################
THEORETICALLY_PROVINCE_ALL_NUMBER="`/usr/bin/expr $THEORETICALLY_PROVINCE_NUMBER + $THEORETICALLY_AGAIN_NATIONWIDE_NUMBER`"

#######################�����ϣ����������ּ���������淨�������ļ�����######################
THEORETICALLY_ALL_POINT_NUMBER="`/usr/bin/expr $THEORETICALLY_NATIONWIDE_NUMBER + $THEORETICALLY_PROVINCE_ALL_NUMBER`"

#######################ʵ���ϣ�������ȫ�����ּ������Ч���������ļ�����########################
ACTUALLY_NATIONWIDE_ALL_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status = '2' and point_type = '0';" | awk 'NR == 3 {print $1}'`"
ACTUALLY_NATIONWIDE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and point_type = '0';" | awk 'NR == 3 {print $1}'`"
ACTUALLY_NATIONWIDE_UNEFFECTIVE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status != '2' and point_type = '0';" | awk 'NR == 3 {print $1}'`"    ######����ȫ�����ּ���handle_status״̬������2�ļ�¼��

#######################ʵ���ϣ�������ʡ�����ּ������Ч���������ļ�����########################
ACTUALLY_PROVINCE_ALL_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status = '2' and point_type = '1';" | awk 'NR == 3 {print $1}'`"

#######################ʵ����,������ʡ���Ʒּ���������ļ�����#############################
ACTUALLY_PROVINCE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and point_type = '1';" | awk 'NR == 3 {print $1}'`"
ACTUALLY_PROVINCE_UNEFFECTIVE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status != '2' and point_type = '1';" | awk 'NR == 3 {print $1}'`"    ####����ʡ���ּ���handle_status״̬������2�ļ�¼��

#######################ʵ���ϣ����������ּ���������淨�������ļ�����######################
ACTUALLY_ALL_POINT_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date;" | awk 'NR == 3 {print $1}'`"

######################ʵ���ϣ����������ּ���������淨����Ч�����ļ�����###################
ACTUALLY_ALL_POINT_EFFECTIVE_NUMBER="`/usr/local/pgsql/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(*) from busi_sell_data_handle_status_t where receive_time >= (current_date - integer '1') and receive_time <= current_date and handle_status = '2';" | awk 'NR == 3 {print $1}'`"

echo "������, '$YESTERDAY' �������ּ���������淨�������ļ�������:$THEORETICALLY_ALL_POINT_NUMBER" >> $SCRIPTDIR/logs.txt
echo "ʵ����, '$YESTERDAY' �������ּ���������淨�������ļ�������:$ACTUALLY_ALL_POINT_NUMBER" >> $SCRIPTDIR/logs.txt
echo "ʵ����, '$YESTERDAY' �������ּ���������淨����Ч�����ļ�������:$ACTUALLY_ALL_POINT_EFFECTIVE_NUMBER" >> $SCRIPTDIR/logs.txt
echo >> $SCRIPTDIR/logs.txt
echo "������, '$YESTERDAY' ����ȫ�����ּ���Ļ��������ļ�������:$THEORETICALLY_NATIONWIDE_NUMBER" >> $SCRIPTDIR/logs.txt
echo "ʵ����, '$YESTERDAY' ����ȫ�����ּ������Ч���������ļ�������:$ACTUALLY_NATIONWIDE_ALL_NUMBER" >> $SCRIPTDIR/logs.txt
echo >> $SCRIPTDIR/logs.txt
echo "������, '$YESTERDAY' ����ʡ�����ּ���Ļ��������ļ�������:$THEORETICALLY_PROVINCE_ALL_NUMBER" >> $SCRIPTDIR/logs.txt
echo "ʵ����, '$YESTERDAY' ����ʡ�����ּ������Ч���������ļ�������:$ACTUALLY_PROVINCE_ALL_NUMBER" >> $SCRIPTDIR/logs.txt
echo >> $SCRIPTDIR/logs.txt
########################################�����ʼ�����#####################################
sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    awk 'NR == '$1'' $SCRIPTDIR/word.txt | mutt -s "`awk 'NR == 1' $SCRIPTDIR/word.txt`$YESTERDAY" $user -F ~/.muttrc2
done
}

#####################################################�ж�#############################
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
