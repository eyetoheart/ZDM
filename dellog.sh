[iwgroup@DEMO2 dellog]$ cat dellog.sh 
#!/bin/sh
SCRIPTDIR="/home/iwgroup/backup/script/dellog"
CONFIGFILE="$SCRIPTDIR/config.txt"

for i in `cat $CONFIGFILE`
do
    delNdayago="`echo $i | awk -F, '{print $1}'`"
    delpath="`echo $i | awk -F, '{print $2}'`"

    if [ -d $delpath ]
    then
        echo "delete directory $delpath  $delNdayago days ago file,`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log 
        cd $delpath
        #find ./ -name "*20*.log"  -mtime "+$delNdayago" | xargs rm -rf {} \;
        find ./ -name "*20*.log"  -mtime "+$delNdayago" -exec rm -rf {} \;  # 2021-01-12 修改为使用-exec执行删除操作，而上面一行xargs的用法不正确；
    fi
done

[iwgroup@DEMO2 dellog]$ cat config.txt 
5,/opt/iwgoup/vasoss4.3/elsm3.1/fat/scheduleProcessor/log/all
5,/opt/iwgoup/vasoss4.3/elsm3.1/fat/scheduleProcessor/log/business
5,/opt/iwgoup/vasoss4.3/elsm3.1/fat/scheduleProcessor/log/message
5,/opt/iwgoup/vasoss4.3/elsm3.1/fat/scheduleProcessor/log/process
5,/opt/iwgoup/vasoss4.3/elsm3.1/fat/scheduleProcessor/log/trace
5,/opt/iwgoup/vasoss4.3/elsm3.1/fat/scheduleProcessor/log/vasoss
5,/opt/iwgoup/vasoss4.3/elsm3.1/uat/scheduleProcessor/log/all
5,/opt/iwgoup/vasoss4.3/elsm3.1/uat/scheduleProcessor/log/business
5,/opt/iwgoup/vasoss4.3/elsm3.1/uat/scheduleProcessor/log/message
5,/opt/iwgoup/vasoss4.3/elsm3.1/uat/scheduleProcessor/log/process
5,/opt/iwgoup/vasoss4.3/elsm3.1/uat/scheduleProcessor/log/trace
5,/opt/iwgoup/vasoss4.3/elsm3.1/uat/scheduleProcessor/log/vasoss
10,/opt/iwgoup/vasoss4.3/bams1.1/fat/scheduleProcessor/log/all
10,/opt/iwgoup/vasoss4.3/bams1.1/fat/scheduleProcessor/log/business
10,/opt/iwgoup/vasoss4.3/bams1.1/fat/scheduleProcessor/log/message
10,/opt/iwgoup/vasoss4.3/bams1.1/fat/scheduleProcessor/log/process
10,/opt/iwgoup/vasoss4.3/bams1.1/fat/scheduleProcessor/log/trace
10,/opt/iwgoup/vasoss4.3/bams1.1/fat/scheduleProcessor/log/vasoss
10,/opt/iwgoup/vasoss4.3/bams1.1/uat/scheduleProcessor/log/all
10,/opt/iwgoup/vasoss4.3/bams1.1/uat/scheduleProcessor/log/business
10,/opt/iwgoup/vasoss4.3/bams1.1/uat/scheduleProcessor/log/message
10,/opt/iwgoup/vasoss4.3/bams1.1/uat/scheduleProcessor/log/process
10,/opt/iwgoup/vasoss4.3/bams1.1/uat/scheduleProcessor/log/trace
10,/opt/iwgoup/vasoss4.3/bams1.1/uat/scheduleProcessor/log/vasoss
