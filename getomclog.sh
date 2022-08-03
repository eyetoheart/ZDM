#!/bin/sh

omcip="10.216.104.221"
omcport="18781"
omcappid="omc36019c0329594ec197f70e05047ea2bf"
omcpath="hb_omc"
filepath="/opt/zaibo"
#woid=""

dbhost="10.120.246.10"
dbuser="root"
dbpasswd=Hbwy\!QAZ2wsx
dbname="carrier_is"

getomcday=`date -d '-1 day' +"%Y-%m-%d"`

getomclog () {

#echo "http://${omcip}:${omcport}/${omcpath}/task/log/$1?appId=${omcappid}"
curl "http://${omcip}:${omcport}/${omcpath}/task/log/$1?appId=${omcappid}" > $filepath/$1.json

}
cd $filepath
sql_taskid='select taskid from dispatch_info where woid = "'$1'" and statues = '7' and getomc_time like "'${getomcday}%'";'
taskid=`mysql -A -u${dbuser} -p${dbpasswd} $dbname -e "${sql_taskid}"`
#echo $taskid
for i in ${taskid[@]}
do
    if [ $i != "taskid" ]
    then
        getomclog $i
        zip -r $1.zip $i.json
        rm -rf $i.json
    fi
done
