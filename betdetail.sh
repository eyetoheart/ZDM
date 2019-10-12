#!/bin/sh
###############################################
## file name : betdetail.sh
## creator:zhangdm
## create time:2019-08-18
## modify time:
## copyright (C) BeiJing IWT Technology Ltd.
###############################################

###################Define Envionment Variables########
SCRIPTDIR="/home/postgres/backup/script/betdetail"
ANHOURAGO="`date -d '-0 day' "+%Y-%m-%d"` 00:00:00"
ANHOURAGO25="`date -d '+1 day' "+%Y-%m-%d"` 00:00:00"

LANG=zh_CN.GBK
export LANG

#DBSERVERSITE="192.168.80.54"
#DBSERVERPORT="5434"
#DBSERVERUSER="postgres"
#DBSERVERDBNAME="lottomagic_test"		## ���ݿ������

DBSERVERSITE="192.168.108.27"
DBSERVERPORT="5432"
DBSERVERUSER="postgres"
DBSERVERDBNAME="lottomagic"

echo "######################################################check betting statistic,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`##########################" >> $SCRIPTDIR/logs.txt
STATUS_NUMBER="`/opt/db/pgsql9/bin/psql -h $DBSERVERSITE -p $DBSERVERPORT -d $DBSERVERDBNAME -c "select count(iwoid) from bet_detail_t  where handle_fail_time>='$ANHOURAGO' and handle_fail_time<'$ANHOURAGO25' and sys_handle_status = 0;" | awk 'NR == 3 {print $1}'`"
#STATUS_NUMBER=1
########################################�����ʼ�����#####################################
sendmailtouser () {
for user in `awk -F, '{print $1}' $SCRIPTDIR/receiver.txt`
do
    echo "now start send mail to $user,time is `date +"%Y-%m-%d %H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    echo -e "From $ANHOURAGO To $ANHOURAGO25\n[ERROR]��������ϵͳ����ϵͳ�Զ��������ȷ��Ͷע�����Ͷע��¼��Ϊ��:"$STATUS_NUMBER | mutt -s "`echo "[ERROR]��������ϵͳ��ϵͳ�Զ��������ȷ��Ͷע�����Ͷע��¼��Ϊ��:"$STATUS_NUMBER`" $user -F ~/.muttrc2
done
}

#####################################################�ж�#############################
if [ $STATUS_NUMBER -eq 0 ]
then
    echo "from $ANHOURAGO to $ANHOURAGO25 lottomagic system bet detail status OK,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
else
    echo "from $ANHOURAGO to $ANHOURAGO25 lottomagic system bet detail status Fail,Now start send mail,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
    sendmailtouser

fi


ϵͳ�ڽᴦ���ƱͶע���ȷ��������

receiver.txt�ļ����ݣ�
13552961152@139.com,yangfan
yangf@iwgroup.com.cn,yangfan
13661089847@139.com,zhangdaoming
rmt@iwgroup.com.cn,yunweibu
13693316141@139.com,liuzhao
liuz@iwgroup.com.cn,liuzhao
