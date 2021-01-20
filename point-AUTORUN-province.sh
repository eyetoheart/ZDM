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
WAITTIME="180"			## 这个数字表示将数据库时间片修改为当前时间再加$WAITTIME秒
POINTTIME="9300"		## 正常情况下,省积分计算的时间 02:35
POINTPORT="16919"		## 省积分计算应用程序端口号
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
DBSERVERDBNAME="pointdb"		## 数据库的名字

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
POINTCAL_SECOND="`expr $CURRENT_SECOND + $WAITTIME`"	## 开始积分计算的时间,10分钟以后开始积分计算
echo $POINTCAL_SECOND

}

##################################重新启动积分计算程序#############################
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

[ ! -s $DOWNTEMP/error${YESTERDAY}.txt ] && exit 0	## search error file,if not exist,then exit,else continue,如果不存在error文件则退出程序

( grep  'AUTORUNprovince' $DOWNTEMP/$YESTERDAY/error${YESTERDAY}.txt > /dev/null 2>&1 ) && { echo "already run province point calculate" >> $SCRIPTDIR/point-FTP.log ; exit 0 ; }	## cheack character "AUTORUNprovince" exist in error file,检查error文件中是否存在AUTORUNprovince字符串,如果存在说明昨天缺少的积分数据已经做过补算

#awk -F[.] '/^14_1000|^41_1000|^45_1000|^61_1000/ {print $1}'  $DOWNTEMP/error${YESTERDAY}.txt >> $DOWNTEMP/error_province_temp.txt	##检查error文件里是否有61和22的数据,这一行只是临时添加上的，所有省的全国玩法不做省积分计算的话将此句注销

#cat $DOWNTEMP/error${YESTERDAY}.txt | awk -F[.] '{print $1}' | awk -F[_] '$2 !~ /10001|10002|10003/{print $0}' >> $DOWNTEMP/error_province_temp.txt	## 将缺少的省玩法的积分数据文件名输出到error_province_temp.txt文件中

awk -F[.] '/^14_1000|^45_1000|^52_1000|^61_1000/ {print $1}'  $DOWNTEMP/error${YESTERDAY}.txt >> $DOWNTEMP/error_province_temp.txt
cat $DOWNTEMP/error${YESTERDAY}.txt | awk -F[.] '{print $1}' | awk -F[_] '$2 !~ /10001|10002|10003/ && $1 !~ /33|41/{print $0}' >> $DOWNTEMP/error_province_temp.txt
##如果缺少山西数据则跳过，手工补算省级和活动积分（2012年3月底结束活动）

[ ! -s $DOWNTEMP/error_province_temp.txt ] && exit 0	## 如果不存在error_province_temp.txt文件说明昨天仅缺少全国积分的数据,所以退出

down_pointdata
cd $DOWNTEMP/$YESTERDAY
for i in `cat $DOWNTEMP/error_province_temp.txt`
do
	ls  $DOWNTEMP/$YESTERDAY/${i}.DAT.* >> $SCRIPTDIR/point-FTP.log  2>&1
	[ $? -ne 0 ] && { rm $DOWNTEMP/error_province_temp.txt ; exit 0 ; }		## 没有在当前目录中找到缺少的省积分数据文件,说明缺少的文件还没有全部下载到本地
	rm -rf $DOWNTEMP/$YESTERDAY/${i}.DAT >> $SCRIPTDIR/point-FTP.log  2>&1
	unzip $DOWNTEMP/$YESTERDAY/${i}.DAT.*  >> $SCRIPTDIR/point-FTP.log 2>&1
	mv ${i}.DAT $DATADIR
	/usr/bin/pscp -l $BAKUSER -pw $BAKPASS $DOWNTEMP/$YESTERDAY/${i}.DAT.* $BAKUSER@$BAKSITE:/home/iwgroup/backup/pointdatabak/$YESTERDAY >> $SCRIPTDIR/point-FTP.log 2>&1
done

################################生成索引文件##################
creat_index_file

#########################creat SQL file,and transfers to DB Server#######################
cd $DOWNTEMP
point_calculate_time="`return_pointcalculate_start_time`"
echo "update sys_time_period_t set cycle_start_time='$point_calculate_time' where iwoid='402881F10B08EAE6010B08EB55B0003D'" > $DOWNTEMP/updatetime
/usr/bin/pscp -l $DBSERVERUSER -pw $DBSERVERPASS $DOWNTEMP/updatetime $DBSERVERUSER@$DBSERVERSITE:$DBSERVERPATH >> $SCRIPTDIR/point-FTP.log 2>&1

###########################在数据库服务器上执行SQL，修改时间片###########
/usr/bin/plink -l $DBSERVERUSER -pw $DBSERVERPASS $DBSERVERUSER@$DBSERVERSITE /usr/local/pgsql/bin/psql -d $DBSERVERDBNAME -f $DBSERVERPATH/updatetime
sleep 3

##########################启动积分计算应用程序#########################
run_point_calculate

############################等待积分计算完成###########################
RETVAL=1
while [ $RETVAL -ne 0 ]
do
	echo "waiting point calculate complete,`date +"%H:%M:%S"`,......." >> $SCRIPTDIR/point-FTP.log
	tail -n 10 $SCRIPTDIR/point.log | grep "基本消费积分计算" | grep "结束" >> $SCRIPTDIR/point-FTP.log 2>&1
	RETVAL=$?
	sleep 30
done
echo "OK! point calculate completed" >> $SCRIPTDIR/point-FTP.log

##########################################将数据库时间片修改成原来时间###################
echo "update sys_time_period_t set cycle_start_time='$POINTTIME' where iwoid='402881F10B08EAE6010B08EB55B0003D'" > $DOWNTEMP/updatetime
/usr/bin/pscp -l $DBSERVERUSER -pw $DBSERVERPASS $DOWNTEMP/updatetime $DBSERVERUSER@$DBSERVERSITE:$DBSERVERPATH >> $SCRIPTDIR/point-FTP.log 2>&1
/usr/bin/plink -l $DBSERVERUSER -pw $DBSERVERPASS $DBSERVERUSER@$DBSERVERSITE /usr/local/pgsql/bin/psql -d $DBSERVERDBNAME -f $DBSERVERPATH/updatetime
sleep 3

#############################################重新启动积分计算应用程序#####################################
run_point_calculate

#############################################删除中彩FTP服务器上的文件,以及data目录下的相关文件#####################################
#delete_pointdata
delete_datadir

#############################################删除程序运行时产生的临时文件##############################
rm -rf $DOWNTEMP/error_province_temp.txt
rm -rf $DOWNTEMP/updatetime

#############################################标记error文件，将AUTORUNprovince字符串写入error文件####################################
echo "AUTORUNprovince"  >> $DOWNTEMP/$YESTERDAY/error${YESTERDAY}.txt
