#!/bin/sh

SCRIPTDIR="/opt/shell"
CONFIGFILE="$SCRIPTDIR/config.txt"
MTIME=60 # seconds
REMTIME=3 # minute
PATH=/usr/jdk1.8.0_271/bin:$PATH:$HOME/bin
JAVA_HOME=/usr/jdk1.8.0_271
export PATH JAVA_HOME

restartapp () {

ps -ef | grep java | grep $2 >> $SCRIPTDIR/logs.txt 2>&1
if [ $? -eq 0 ]
then
    cd $1/bin
    ./shutdown.sh >> $SCRIPTDIR/logs.txt 2>&1
    sleep 5
    ps -ef | grep java | grep $2 >> $SCRIPTDIR/logs.txt 2>&1
    if [ $? -eq 0 ]
    then
        uidnum="`ps -ef | grep java | grep $2 | awk '{print $2}'`"
        kill -9 $uidnum
        sleep 5
        cd $1/bin
        ./startup.sh >> $SCRIPTDIR/logs.txt 2>&1
    else
        cd $1/bin
        ./startup.sh >> $SCRIPTDIR/logs.txt 2>&1
    fi
else
    cd $1/bin
    ./startup.sh
fi

}

while sleep $MTIME
do
    for app in `cat $CONFIGFILE`
    do
    {
        APPDIR="`echo $app | awk -F: '{print $1}'`"
        DATADIR="`echo $app | awk -F: '{print $2}'`"
        EXCLDIR="`echo $app | awk -F: '{print $3}'`"
        APPNAME="`basename $APPDIR`"
        if [ -z "$EXCLDIR" ]
        then
            echo "check $DATADIR `date +"%Y-%m-%d_%H:%M:%S"` ..." >> $SCRIPTDIR/logs.txt
            cd $DATADIR
            find $DATADIR -mmin -1 -print  > $SCRIPTDIR/${APPNAME}_changfile.txt
            if [ -s $SCRIPTDIR/${APPNAME}_changfile.txt ]
            then
                while [ -s $SCRIPTDIR/${APPNAME}_changfile.txt ]
                do
                    echo "$DATADIR has been updated,now wait $REMTIME minute,If the dir is updated again during this period, it will be postponed to the next $REMTIME minutes again,`date +"%Y-%m-%d_%H:%M:%S"` ..." >> $SCRIPTDIR/logs.txt
                    sleep $REMTIME
                    cd $DATADIR
                    find $DATADIR -mmin -$REMTIME -print  > $SCRIPTDIR/${APPNAME}_changfile.txt
                done
                echo "now restart $APPNAME,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
                restartapp $APPDIR $APPNAME
            fi
        else
            echo "check $DATADIR `date +"%Y-%m-%d_%H:%M:%S"` ..." >> $SCRIPTDIR/logs.txt
            cd $DATADIR
            find $DATADIR -path "$EXCLDIR" -prune -o -mmin -1 -print > $SCRIPTDIR/${APPNAME}_changfile.txt
            if [ -s $SCRIPTDIR/${APPNAME}_changfile.txt ]
            then
                while [ -s $SCRIPTDIR/${APPNAME}_changfile.txt ]
                do
                    echo "$DATADIR has been updated,now wait $REMTIME minute,If the dir is updated again during this period, it will be postponed to the next $REMTIME minutes again,`date +"%Y-%m-%d_%H:%M:%S"` ..." >> $SCRIPTDIR/logs.txt
                    sleep $REMTIME
                    cd $DATADIR
                    find $DATADIR -path "$EXCLDIR" -prune -o -mmin -$REMTIME -print > $SCRIPTDIR/${APPNAME}_changfile.txt
                done
                echo "now restart $APPNAME,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.txt
                restartapp $APPDIR $APPNAME
            fi
        fi
    }&
    done
    wait
done




脚本文件同目录下config.txt为脚本的配置文件，该配置文件以":"分割3列，第一列为程序目录，即tomcat部署位置；第二列是数据目录，即部署jar包的位置，第三列为排除目录，此目录下即便有文件 更新也不重新应用，第三列可有可无，非必须列，以下是例子：
/opt/tomcat-1:/data/test_dir_1:/data/test_dir_1/manager
/opt/tomcat-2:/data/test_dir_2
脚本监控第二列所在目录下文件是否有更新，如果有更新则等待N分钟，然后重启应用，等待期间如再有文件更新，则再等待N分钟，直到N分钟之内无文件更新时再重启应用。

配置文件config.txt的内容如下：
/opt/tomcat-1:/data/test_dir_1:/data/test_dir_1/manager
/opt/tomcat-2:/data/test_dir_2 
