#!/bin/sh
scriptdir="/tiankui/scripts"
pmdir="/tiankui/rlyj/csvCollect/csvfile/pm_data"
pmhost="82.221.6.154"
pmuser="admin"
pmpass='disneyCZ!553_154'

lasttime="`date -d '-1 hour' +"%Y%m%d%H"`"
#echo $lasttime  >> $scriptdir/log.txt

upfile () {

/usr/local/bin/pscp -l $pmuser -pw ${pmpass}  ${pmdir}/pm_data_${lasttime}.csv  ${pmuser}@${pmhost}:/tiankui/PGapptest/capacity/pm_data >> $scriptdir/log.txt 2>&1

}

grep "pm_data_${lasttime}" $scriptdir/already.txt > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "alread put pm_data_${lasttime}.csv to 82.221.6.154 `date`" >> $scriptdir/log.txt
    exit 0
fi

ls  $pmdir/pm_data_${lasttime}.csv > /dev/null 2>&1

if [ $? -eq 0 ]
then
    localmd5sum="`md5sum $pmdir/pm_data_${lasttime}.csv | awk '{print $1}'`"
    remotemd5sum=
    until [ "a${localmd5sum}" = "a${remotemd5sum}" ]
    do
        upfile
        remotemd5sum=`/usr/local/bin/plink -batch -l $pmuser -pw ${pmpass} ${pmuser}@${pmhost} md5sum /tiankui/PGapptest/capacity/pm_data/pm_data_${lasttime}.csv | awk -F[\ ] '{print $1}'`
    done
    echo "transfer OK,`date`" >> $scriptdir/log.txt
    echo "pm_data_${lasttime}.csv file already put to $pmhost `date`" >> $scriptdir/already.txt
fi
