#!/bin/sh
#############################################
## file name : synctoapp.sh
## creator:zhangdm
## create time:2017-07-06
## modify time:2017-07-06
## copyright (C) BeiJing IWT Technology Ltd.
#############################################

SCRIPTDIR="/home/oracle/backup/script/synctoapp_uat3"

SOURCEDIR="/oracle/dir/fundsystem3.1/uat"
PLATCONFIG="/home/oracle/backup/script/synctoapp_uat3/platformid.conf"
BACKUPDIR="/home/oracle/backup/databak/synctoapp_uat3"

DATEFORMAT="`date -d '-0 day' "+%Y-%m-%d_%H-%M-%S"`"

APPSERVER="192.168.80.73"
APPSERVERUSER="iwgroup"
APPSERVERPASS='abcdefg123456'

creat_flag () {

/usr/local/bin/plink -l $APPSERVERUSER -pw $APPSERVERPASS $APPSERVERUSER@$APPSERVER touch $1/$2 >> $SCRIPTDIR/logs.log  2>&1

}

upfiletoapp () {

/usr/local/bin/pscp -l $APPSERVERUSER -pw $APPSERVERPASS $2 $APPSERVERUSER@$APPSERVER:$1/$2 >> $SCRIPTDIR/logs.log  2>&1

}

echo "-------------------------------------------check file exist or not,`date +"%Y_%m_%d_%H:%M:%S"`----------------------------------" >> $SCRIPTDIR/logs.log
cd $SOURCEDIR
ls -1 *.* > $SCRIPTDIR/filetemp.txt  2>>  $SCRIPTDIR/logs.log 
if [ -s $SCRIPTDIR/filetemp.txt ]
then
    echo "The directory has files,now start transport......" >> $SCRIPTDIR/logs.log
    for i in `cat $SCRIPTDIR/filetemp.txt`
    do
        cd $SOURCEDIR
        echo "transport file $i to $APPSERVER,`date +"%Y_%m_%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
        PLATID=`echo $i | awk -F[-] '{print $1}'`
        APPPATH=`grep $PLATID $PLATCONFIG | awk -F[:] '{print $2}'`
        case "$PLATID" in
        11000000|21000000|31000000|61000000)
            upfiletoapp  $APPPATH/checkToPlatformCleartext  $i
#            upfiletoapp  $APPPATH/checkToPlatform  $i
#            creat_flag  $APPPATH/checkToPlatformFlag  $i
            ;;
        batchTrading)
            upfiletoapp  $APPPATH  $i
            ;;
        *)
            APPPATH=`grep  other  $PLATCONFIG | awk -F[:] '{print $2}'`
            OAPPPATH=`echo $i | awk -F[-] '{for (i=1;i<NF - 1;i++) printf("%s-",$i)}' | sed 's/.$//'`
            upfiletoapp  $APPPATH/$OAPPPATH/cleartext  $i
#            upfiletoapp  $APPPATH/$OAPPPATH/data  $i
#            creat_flag  $APPPATH/$OAPPPATH/flag $i
            ;;
        esac
        zip    $BACKUPDIR/FUNDS_${DATEFORMAT}.ZIP  $i >> $SCRIPTDIR/logs.log  2>&1
        rm -rf $i
    done
fi
cd $SCRIPTDIR
rm -rf  filetemp.txt
