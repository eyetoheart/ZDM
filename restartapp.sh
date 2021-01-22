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
