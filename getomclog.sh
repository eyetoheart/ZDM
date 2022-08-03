#!/bin/sh

omcip="192.168.10.10"
omcport="18781"
omcappid="omc36019c0329594ec197f70a2bf"
omcpath="hb_omc"
filepath="/opt/zaibo"
#woid=""

dbhost="192.168.10.10"
dbuser="root"
dbpasswd=password
dbname="carrie"

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
