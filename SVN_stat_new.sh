#!/bin/sh

SCRIPT="/home/iwgoup/backup/script/SVN_stat"
PASSFILE="/disk/arch/SVNWork/project/passwd"
LOGDIR="/usr/local/apache2/logs/"
DATAFORMAT="`date -d '-0 day' "+%Y-%m-%d"`"
LANG=zh_CN.UTF-8
export LANG

sendmailtouser () { 

cd $SCRIPT/file
for i in `awk -F, '{print $1}' $SCRIPT/receiver.txt`
do
    echo "now start send mail to $i,time is `date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPT/logs.log
    echo "SVN各账号更新次数统计:$DATAFORMAT" | mutt -s "SVN账号更新次数统计:$DATAFORMAT" $i -a access_${DATAFORMAT}.log
done
}

for user in `awk -F: '$1 !~ /^#/{print $1}' $PASSFILE`
do
    echo -n "$user"":" >> $SCRIPT/access.txt
    grep -c $user  $LOGDIR/access_${DATAFORMAT}.log >> $SCRIPT/logs.log 2>> $SCRIPT/error.log
    if [ $? -ne 0 ]
    then
        echo 0 >> $SCRIPT/access.txt
    else
        grep -c $user  $LOGDIR/access_${DATAFORMAT}.log >> $SCRIPT/access.txt
    fi
done
sort -n -t ':' -k2rn  $SCRIPT/access.txt > $SCRIPT/file/access_${DATAFORMAT}.log
cd $SCRIPT
rm -rf access.txt
sendmailtouser
echo "----------`date +"%Y-%m-%d_%H:%M:%S"`--------------" >> $SCRIPT/logs.log
