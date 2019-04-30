#!/bin/sh

SCRIPT="/home/iwgroup/backup/script"
PASSFILE="/opt/SVNWork/project/passwd"
LOGDIR="/usr/local/apache2/logs/"
DATAFORMAT="`date -d '-1 day' "+%Y-%m-%d"`"
LANG=zh_CN.GBK
export LANG

sendmailtouser () { 

cd $SCRIPT
for i in `awk -F, '{print $1}' $SCRIPT/receiver.txt`
do
    #echo "now start send mail to $i,time is `date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPT/logs.log
    echo "SVN各账号更新次数统计:$DATAFORMAT" | mutt -s "SVN各账号更新次数统计:$DATAFORMAT" -a $SCRIPT/access_${DATAFORMAT}.log  -a $SCRIPT/JXPS_SVN_access_${DATAFORMAT}.log  $i
done

}


for user in `awk -F: '$1 !~ /^#/{print $1}' $PASSFILE`
do
    echo -n "$user"":" >> $SCRIPT/access.txt
    grep -c $user  $LOGDIR/access_${DATAFORMAT}.log >> $SCRIPT/access.txt
done
sort -n -t ':' -k2rn  $SCRIPT/access.txt > $SCRIPT/access_${DATAFORMAT}.log
cd $SCRIPT
rm -rf access.txt

sendmailtouser
