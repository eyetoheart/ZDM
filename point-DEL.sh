#!/bin/sh

SCRIPTDIR="/path"
DOWNTEMP="/path"
DATADIR="/path"
DATADIRprovince="/path"
DATADIRprovinceActive="/path"
MERGESOURCEDIR="/path"
MERGEDESTDIR="/path"
MERGEFILTERDIR="/path"
FILTERSOURCEDIR="/path"
FILTERINCLUDEDIR="/path"
FILTEREXCLUDEDIR="/path"

YESTDATEFULL="`date -d '-1 day' "+%Y-%m-%d"`"

JIFENFTPSITE="xxx.xxx.xxx.xxx"
JIFENFTPUSER="access"
JIFENFTPPASS="passwd"

##################Define Function,delete point data from zhongcai FTP site###################
delete_ftpsitefile () {  

cd $DOWNTEMP/$YESTDATEFULL
#ls -1 *.DAT.* > $DOWNTEMP/filelist.txt
for i in `cat $DOWNTEMP/list.txt`
do
    echo "open $JIFENFTPSITE" > $SCRIPTDIR/ftptask.txt
    echo "user $JIFENFTPUSER $JIFENFTPPASS" >> $SCRIPTDIR/ftptask.txt
    echo "verbose" >> $SCRIPTDIR/ftptask.txt
    echo "binary" >> $SCRIPTDIR/ftptask.txt
    echo "delete $i" >> $SCRIPTDIR/ftptask.txt
    echo "close" >> $SCRIPTDIR/ftptask.txt
    echo "bye" >> $SCRIPTDIR/ftptask.txt
    echo "start delete $i file from zhongcai FTP site,`date +"%Y-%m-%d_%H:%M:%S"`" >>  $SCRIPTDIR/point-FTP.log 2>&1
    ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/point-FTP.log 2>&1
    sleep 1
done
rm -rf $SCRIPTDIR/ftptask.txt >>  $SCRIPTDIR/point-FTP.log 2>&1
rm -rf $DOWNTEMP/list.txt >>  $SCRIPTDIR/point-FTP.log 2>&1
  
}

delete_datadir () {
cd $DATADIR
echo "start delete $DATADIR" >> $SCRIPTDIR/point-FTP.log
rm *VIP.DAT >>  $SCRIPTDIR/point-FTP.log 2>&1
rm sell_file_index.txt >>  $SCRIPTDIR/point-FTP.log 2>&1

cd $DATADIRprovince
echo "start delete $DATADIRprovince" >> $SCRIPTDIR/point-FTP.log
rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1
rm sell_file_index.txt >>  $SCRIPTDIR/point-FTP.log 2>&1

#cd $DATADIRprovinceActive
#echo "start delete $DATADIRprovinceActive" >> $SCRIPTDIR/point-FTP.log
#rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1
#rm sell_file_index.txt >>  $SCRIPTDIR/point-FTP.log 2>&1

#cd $MERGESOURCEDIR
#echo "start delete $MERGESOURCEDIR" >> $SCRIPTDIR/point-FTP.log
#rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1

#cd $MERGEDESTDIR
#echo "start delete $MERGEDESTDIR" >> $SCRIPTDIR/point-FTP.log
#rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1

#cd $MERGEFILTERDIR
#echo "start delete $MERGEFILTERDIR" >> $SCRIPTDIR/point-FTP.log
#rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1
   
cd $FILTERSOURCEDIR
echo "start delete $FILTERSOURCEDIR" >> $SCRIPTDIR/point-FTP.log
rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1

cd $FILTERINCLUDEDIR
echo "start delete $FILTERINCLUDEDIR"  >> $SCRIPTDIR/point-FTP.log
rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1

cd $FILTEREXCLUDEDIR
echo "start delete $FILTERSOURCEDIR" >> $SCRIPTDIR/point-FTP.log
rm *VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1

}
cd $DOWNTEMP/$YESTDATEFULL
echo "start delete point file from zhongcai FTP site,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/point-FTP.log 2>&1
delete_ftpsitefile
echo "start delete point file and sell_file_index.txt file from data dirctory,`date +"%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/point-FTP.log 2>&1
delete_datadir

#rm -rf $DOWNTEMP/list.txt
