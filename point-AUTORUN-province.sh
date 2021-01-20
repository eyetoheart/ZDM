#!/bin/sh
###############################################
## file name : point-AUTORUN-province.sh
## creator:zhangdm
## create time:2009-05-10
## modify time:2009-07-05
## copyright (C) BeiJing IWT Technology Ltd.
###############################################

###################Define Envionment Variables########
SCRIPTDIR="/opt/iwgroup/vasoss/point-calculate-server-province/bin"
DOWNTEMP="/opt/iwgroup/vasoss/point-calculate-server/downtemp"
DATADIR="/opt/iwgroup/vasoss/point-calculate-server-province/data_province"

#YESTERDAY="`date --date="yesterday" "+%Y-%m-%d"`"
YESTERDAY="`date -d '-2 day' "+%Y-%m-%d"`"
WAITTIME="180"			## ������ֱ�ʾ�����ݿ�ʱ��Ƭ�޸�Ϊ��ǰʱ���ټ�$WAITTIME��
POINTTIME="9300"		## ���������,ʡ���ּ����ʱ�� 02:35
POINTPORT="16919"		## ʡ���ּ���Ӧ�ó���˿ں�
LANG=zh_CN.GB2312
export LANG

JIFENFTPSITE="192.168.63.2"
JIFENFTPUSER="vip"
JIFENFTPPASS="123456"

BAKSITE="192.168.80.36"
#BAKSITE=219.234.252.163
BAKUSER="iwgroup"
BAKPASS='password'

DBSERVERSITE="192.168.60.20"
DBSERVERUSER="postgres"
DBSERVERPASS='password'
DBSERVERPATH="/home/postgres"
DBSERVERDBNAME="pointdb"		## ���ݿ������

##################Define Function,download point data from zhongcai FTP site######################
down_pointdata () {

cd $DOWNTEMP/$YESTERDAY
for i in `cat $DOWNTEMP/error_province_temp.txt`
do
	echo "open $JIFENFTPSITE" > $SCRIPTDIR/ftptask.txt
	echo "user $JIFENFTPUSER $JIFENFTPPASS" >> $SCRIPTDIR/ftptask.txt
	echo "verbose" >> $SCRIPTDIR/ftptask.txt
	echo "binary" >> $SCRIPTDIR/ftptask.txt
	echo "mget ${i}.DAT.*" >> $SCRIPTDIR/ftptask.txt
	echo "close" >> $SCRIPTDIR/ftptask.txt
	echo "bye" >> $SCRIPTDIR/ftptask.txt
	echo "now start download ${i}.DAT file from zhongcai FTP site,`date +"%Y-%m-%d_%H:%M:%S"`" >>  $SCRIPTDIR/point-FTP.log 2>&1
	ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/point-FTP.log 2>&1
	sleep 1
done
rm $SCRIPTDIR/ftptask.txt

}

##################Define Function,delete point data from zhongcai FTP site########################
delete_pointdata () {  

cd $DATADIR
for i in `cat $DOWNTEMP/error_province_temp.txt`
do
        echo "open $JIFENFTPSITE" > $SCRIPTDIR/ftptask.txt
        echo "user $JIFENFTPUSER $JIFENFTPPASS" >> $SCRIPTDIR/ftptask.txt
        echo "verbose" >> $SCRIPTDIR/ftptask.txt
        echo "binary" >> $SCRIPTDIR/ftptask.txt
        echo "mdelete ${i}.DAT.*" >> $SCRIPTDIR/ftptask.txt
        echo "close" >> $SCRIPTDIR/ftptask.txt
        echo "bye" >> $SCRIPTDIR/ftptask.txt
        echo "now start delete ${i}.DAT file from zhongcai FTP site,`date +"%Y-%m-%d_%H:%M:%S"`" >>  $SCRIPTDIR/point-FTP.log 2>&1
        ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/point-FTP.log 2>&1
        sleep 1
done
rm $SCRIPTDIR/ftptask.txt >>  $SCRIPTDIR/point-FTP.log 2>&1
 
}

###########################################################
delete_datadir () {    

cd $DATADIR
rm *VIP.DAT >>  $SCRIPTDIR/point-FTP.log 2>&1
rm sell_file_index.txt >>  $SCRIPTDIR/point-FTP.log 2>&1

}

##################Define Function,create new sell file,and move sell file to data directory#####
creat_index_file () {

echo $YESTERDAY > $DATADIR/sell_file_index.txt
cd $DATADIR
ls -1 *VIP.DAT >> $DATADIR/sell_file_index.txt
echo "ok" >> $DATADIR/sell_file_index.txt

}

#################Define Function,ruturn Envionment Variables############
return_pointcalculate_start_time () {

CURRENT_HOUR="`date +"%H"`"
CURRENT_MINUTE="`date +"%M"`"
CURRENT_SECOND="`expr $CURRENT_HOUR \* 3600 + $CURRENT_MINUTE \* 60`"
POINTCAL_SECOND="`expr $CURRENT_SECOND + $WAITTIME`"	## ��ʼ���ּ����ʱ��,10�����Ժ�ʼ���ּ���
echo $POINTCAL_SECOND

}

##################################�����������ּ������#############################
run_point_calculate () {

ps -ef | grep java | grep $POINTPORT >> $SCRIPTDIR/point-FTP.log 2>&1
if [ $? -eq 0 ]
then
	cd $SCRIPTDIR
	. shutdown.sh
	sleep 10
	ps -ef | grep java | grep $POINTPORT  >>  $SCRIPTDIR/point-FTP.log 2>&1
	if [ $? -eq 0 ]
	then
		idnumber="`ps -ef | grep java | grep $POINTPORT | awk '{print $2}'`"
		kill -9 $idnumber
		sleep 5
		cd $SCRIPTDIR
		. startup.sh
	else
		cd $SCRIPTDIR
		. startup.sh
	fi
else
	cd $SCRIPTDIR
	. startup.sh
fi
	
}

##################check error file exist or no in the downtemp dirctory###########
echo "-------------------------AUTO run province point-calculate, `date +"%Y-%m-%d %H:%M:%S"`---------------------" >> $SCRIPTDIR/point-FTP.log

[ ! -s $DOWNTEMP/error${YESTERDAY}.txt ] && exit 0	## search error file,if not exist,then exit,else continue,���������error�ļ����˳�����

( grep  'AUTORUNprovince' $DOWNTEMP/$YESTERDAY/error${YESTERDAY}.txt > /dev/null 2>&1 ) && { echo "already run province point calculate" >> $SCRIPTDIR/point-FTP.log ; exit 0 ; }	## cheack character "AUTORUNprovince" exist in error file,���error�ļ����Ƿ����AUTORUNprovince�ַ���,�������˵������ȱ�ٵĻ��������Ѿ���������

#awk -F[.] '/^14_1000|^41_1000|^45_1000|^61_1000/ {print $1}'  $DOWNTEMP/error${YESTERDAY}.txt >> $DOWNTEMP/error_province_temp.txt	##���error�ļ����Ƿ���61��22������,��һ��ֻ����ʱ����ϵģ�����ʡ��ȫ���淨����ʡ���ּ���Ļ����˾�ע��

#cat $DOWNTEMP/error${YESTERDAY}.txt | awk -F[.] '{print $1}' | awk -F[_] '$2 !~ /10001|10002|10003/{print $0}' >> $DOWNTEMP/error_province_temp.txt	## ��ȱ�ٵ�ʡ�淨�Ļ��������ļ��������error_province_temp.txt�ļ���

awk -F[.] '/^14_1000|^45_1000|^52_1000|^61_1000/ {print $1}'  $DOWNTEMP/error${YESTERDAY}.txt >> $DOWNTEMP/error_province_temp.txt
cat $DOWNTEMP/error${YESTERDAY}.txt | awk -F[.] '{print $1}' | awk -F[_] '$2 !~ /10001|10002|10003/ && $1 !~ /33|41/{print $0}' >> $DOWNTEMP/error_province_temp.txt
##���ȱ��ɽ���������������ֹ�����ʡ���ͻ���֣�2012��3�µ׽������

[ ! -s $DOWNTEMP/error_province_temp.txt ] && exit 0	## ���������error_province_temp.txt�ļ�˵�������ȱ��ȫ�����ֵ�����,�����˳�

down_pointdata
cd $DOWNTEMP/$YESTERDAY
for i in `cat $DOWNTEMP/error_province_temp.txt`
do
	ls  $DOWNTEMP/$YESTERDAY/${i}.DAT.* >> $SCRIPTDIR/point-FTP.log  2>&1
	[ $? -ne 0 ] && { rm $DOWNTEMP/error_province_temp.txt ; exit 0 ; }		## û���ڵ�ǰĿ¼���ҵ�ȱ�ٵ�ʡ���������ļ�,˵��ȱ�ٵ��ļ���û��ȫ�����ص�����
	rm -rf $DOWNTEMP/$YESTERDAY/${i}.DAT >> $SCRIPTDIR/point-FTP.log  2>&1
	unzip $DOWNTEMP/$YESTERDAY/${i}.DAT.*  >> $SCRIPTDIR/point-FTP.log 2>&1
	mv ${i}.DAT $DATADIR
	/usr/bin/pscp -l $BAKUSER -pw $BAKPASS $DOWNTEMP/$YESTERDAY/${i}.DAT.* $BAKUSER@$BAKSITE:/home/iwgroup/backup/pointdatabak/$YESTERDAY >> $SCRIPTDIR/point-FTP.log 2>&1
done

################################���������ļ�##################
creat_index_file

#########################creat SQL file,and transfers to DB Server#######################
cd $DOWNTEMP
point_calculate_time="`return_pointcalculate_start_time`"
echo "update sys_time_period_t set cycle_start_time='$point_calculate_time' where iwoid='402881F10B08EAE6010B08EB55B0003D'" > $DOWNTEMP/updatetime
/usr/bin/pscp -l $DBSERVERUSER -pw $DBSERVERPASS $DOWNTEMP/updatetime $DBSERVERUSER@$DBSERVERSITE:$DBSERVERPATH >> $SCRIPTDIR/point-FTP.log 2>&1

###########################�����ݿ��������ִ��SQL���޸�ʱ��Ƭ###########
/usr/bin/plink -l $DBSERVERUSER -pw $DBSERVERPASS $DBSERVERUSER@$DBSERVERSITE /usr/local/pgsql/bin/psql -d $DBSERVERDBNAME -f $DBSERVERPATH/updatetime
sleep 3

##########################�������ּ���Ӧ�ó���#########################
run_point_calculate

############################�ȴ����ּ������###########################
RETVAL=1
while [ $RETVAL -ne 0 ]
do
	echo "waiting point calculate complete,`date +"%H:%M:%S"`,......." >> $SCRIPTDIR/point-FTP.log
	tail -n 10 $SCRIPTDIR/point.log | grep "�������ѻ��ּ���" | grep "����" >> $SCRIPTDIR/point-FTP.log 2>&1
	RETVAL=$?
	sleep 30
done
echo "OK! point calculate completed" >> $SCRIPTDIR/point-FTP.log

##########################################�����ݿ�ʱ��Ƭ�޸ĳ�ԭ��ʱ��###################
echo "update sys_time_period_t set cycle_start_time='$POINTTIME' where iwoid='402881F10B08EAE6010B08EB55B0003D'" > $DOWNTEMP/updatetime
/usr/bin/pscp -l $DBSERVERUSER -pw $DBSERVERPASS $DOWNTEMP/updatetime $DBSERVERUSER@$DBSERVERSITE:$DBSERVERPATH >> $SCRIPTDIR/point-FTP.log 2>&1
/usr/bin/plink -l $DBSERVERUSER -pw $DBSERVERPASS $DBSERVERUSER@$DBSERVERSITE /usr/local/pgsql/bin/psql -d $DBSERVERDBNAME -f $DBSERVERPATH/updatetime
sleep 3

#############################################�����������ּ���Ӧ�ó���#####################################
run_point_calculate

#############################################ɾ���в�FTP�������ϵ��ļ�,�Լ�dataĿ¼�µ�����ļ�#####################################
#delete_pointdata
delete_datadir

#############################################ɾ����������ʱ��������ʱ�ļ�##############################
rm -rf $DOWNTEMP/error_province_temp.txt
rm -rf $DOWNTEMP/updatetime

#############################################���error�ļ�����AUTORUNprovince�ַ���д��error�ļ�####################################
echo "AUTORUNprovince"  >> $DOWNTEMP/$YESTERDAY/error${YESTERDAY}.txt
