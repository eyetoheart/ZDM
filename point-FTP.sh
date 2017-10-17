#!/bin/sh
#############################################
## file name : point-FTP.sh
## creator:zhangdm
## create time:2007-06-11  by zhangdm
## copyright (C) BeiJing IWT Technology Ltd.
#############################################
###################Define Envionment Variables########
SCRIPTDIR="/path1"
DOWNTEMP="/path2"
DATADIR="/path3"
DOWNTEMPprovince="/path4"
DATADIRprovince="/path5"
CONFIGFILE="/path/config-file.txt"
MERGEDIR="/path6/sourceFolder"
GUANGXIDIR="/path7"

ZDOWNTEMP="/path8"
ZDATADIR="/path9"
ZSITE="xxx.xxx.xxx.xxx"
ZUSER="access"
ZPASS='passwd'

JXDOWNTEMP="/path10"
JXDATADIR="/path11"
JXSITE="xxx.xxx.xxx.xxx"
JXUSER="access"
JXPASS='passwd'

#DATEDAY="`date +"%Y-%m-%d"`"
#DATEDAY="`date --date="yesterday" "+%Y-%m-%d"`"
DATEDAY="`date -d '-1 day' "+%Y-%m-%d"`"

JIFENFTPSITE="xxx.xx.xxx.xxx"
JIFENFTPUSER="access"
JIFENFTPPASS="passwd"

##################Define Function,create new sell file,and move sell file to data directory#####
creat_index_file () {

echo $DATEDAY > $DOWNTEMP/sell_file_index.txt
cd $DATADIR
ls -1 *VIP.DAT >> $DOWNTEMP/sell_file_index.txt
echo "ok" >> $DOWNTEMP/sell_file_index.txt
cp $DOWNTEMP/sell_file_index.txt  $DATADIR
cp $DOWNTEMP/sell_file_index.txt  $DOWNTEMP/$DATEDAY/sell_file_index_country.txt

echo $DATEDAY > $DOWNTEMPprovince/sell_file_index.txt
cd $DATADIRprovince
ls -1 *VIP.DAT >> $DOWNTEMPprovince/sell_file_index.txt
echo "ok" >> $DOWNTEMPprovince/sell_file_index.txt
cp $DOWNTEMPprovince/sell_file_index.txt  $DATADIRprovince
cp $DOWNTEMPprovince/sell_file_index.txt  $DOWNTEMP/$DATEDAY/sell_file_index_province.txt

}

##############Define Function,download point data from zhongcai FTP site###############
down_pointdata () {

cd $DOWNTEMP/$DATEDAY
#for i in `grep $DATEDAY $CONFIGFILE | awk -F[,]  '{print $1"_"$2"_"$3}'`
for i in `grep $DATEDAY $CONFIGFILE | awk -F[,]  '{print $1"_"$2"_"$3}' | grep -v ^41_ `
do

    echo "open $JIFENFTPSITE" > $SCRIPTDIR/ftptask.txt
    echo "user $JIFENFTPUSER $JIFENFTPPASS" >> $SCRIPTDIR/ftptask.txt
    echo "verbose" >> $SCRIPTDIR/ftptask.txt
    echo "binary" >> $SCRIPTDIR/ftptask.txt
    echo "mget $i*" >> $SCRIPTDIR/ftptask.txt
    echo "close" >> $SCRIPTDIR/ftptask.txt
    echo "bye" >> $SCRIPTDIR/ftptask.txt
    ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/point-FTP.log 2>&1
done
rm $SCRIPTDIR/ftptask.txt

}
#####################################################################################

creat_list () {

cd $DOWNTEMP/
echo "open $JIFENFTPSITE" > $SCRIPTDIR/ftptask.txt
echo "user $JIFENFTPUSER $JIFENFTPPASS" >> $SCRIPTDIR/ftptask.txt
echo "verbose" >> $SCRIPTDIR/ftptask.txt
echo "binary" >> $SCRIPTDIR/ftptask.txt
echo "mls -R10 $DOWNTEMP/list.txt"  >> $SCRIPTDIR/ftptask.txt
echo "close" >> $SCRIPTDIR/ftptask.txt
echo "bye" >> $SCRIPTDIR/ftptask.txt
ftp -vin < $SCRIPTDIR/ftptask.txt >> $SCRIPTDIR/point-FTP.log 2>&1
rm $SCRIPTDIR/ftptask.txt
}

#######################uncompress data file and move data file to data directory#######
unzip_pointfile () {

cd $DOWNTEMP/$DATEDAY
for i in `ls *VIP.DAT.*`
do
    unzip $i >> $SCRIPTDIR/point-FTP.log 2>&1
done

}
##########################check point data file,and create error file################
check_point_file_miss () { 

cd $DOWNTEMP/$DATEDAY
#for i in `grep $DATEDAY $CONFIGFILE | awk -F[,]  '{print $1"_"$2"_"$3}'`
for i in `grep $DATEDAY $CONFIGFILE | awk -F[,]  '{print $1"_"$2"_"$3}' | grep -v ^41_ `
do
    [ ! -s ${i}_VIP.DAT ] && echo "${i}_VIP.DAT file is not exist" >> $DOWNTEMP/error${DATEDAY}.txt
done

}

##################################################province point file process######################
copy_data_to_province () {
cd $DOWNTEMP/$DATEDAY

mv $DOWNTEMP/$DATEDAY/45_1000*_*_VIP.DAT $GUANGXIDIR >> $SCRIPTDIR/point-FTP.log 2>&1
mv $DOWNTEMP/$DATEDAY/45_45001_*_VIP.DAT $GUANGXIDIR >> $SCRIPTDIR/point-FTP.log 2>&1
mv $DOWNTEMP/$DATEDAY/45_45022_*_VIP.DAT $GUANGXIDIR >> $SCRIPTDIR/point-FTP.log 2>&1
mv $DOWNTEMP/$DATEDAY/35_9001*_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1
#mv $DOWNTEMP/$DATEDAY/36_9001*_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1
#mv $DOWNTEMP/$DATEDAY/41_41001_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1
#mv $DOWNTEMP/$DATEDAY/52_52002_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1

cp $DOWNTEMP/$DATEDAY/14_1000*_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1
cp $DOWNTEMP/$DATEDAY/61_1000*_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1
#cp $DOWNTEMP/$DATEDAY/41_1000*_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1
#cp $DOWNTEMP/$DATEDAY/52_1000*_*_VIP.DAT $DATADIRprovince >> $SCRIPTDIR/point-FTP.log 2>&1

################################################## pscp 33_*_VIP.DAT to z server ################
echo $DATEDAY > $DOWNTEMP/$DATEDAY/sell_file_index_zzip_province.txt
ls -1 33_*_VIP.DAT >>  $DOWNTEMP/$DATEDAY/sell_file_index_zzip_province.txt
echo "ok" >> $DOWNTEMP/$DATEDAY/sell_file_index_zzip_province.txt
zip zprovince-$DATEDAY.zip 33_*_VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1
/usr/bin/pscp -l $ZUSER -pw $ZPASS $DOWNTEMP/$DATEDAY/zprovince-$DATEDAY.zip $ZUSER@$ZSITE:$ZDOWNTEMP >> $SCRIPTDIR/point-FTP.log 2>&1

#{ /usr/bin/plink -l $ZUSER -pw $ZPASS $ZUSER@$ZSITE  unzip  $ZDOWNTEMP/zprovince-$DATEDAY.zip -d $ZDATADIR >> $SCRIPTDIR/point-FTP.log 2>&1 ;}  && /usr/bin/pscp -l $ZUSER -pw $ZPASS $DOWNTEMP/$DATEDAY/sell_file_index_zzip_province.txt $ZUSER@$ZSITE:$ZDATADIR/sell_file_index.txt >> $SCRIPTDIR/point-FTP.log 2>&1 

{ /usr/bin/plink -l $ZUSER -pw $ZPASS $ZUSER@$ZSITE  unzip  $ZDOWNTEMP/zprovince-$DATEDAY.zip -d $ZDATADIR >> $SCRIPTDIR/point-FTP.log 2>&1 ;}  && /usr/bin/pscp -l $ZUSER -pw $ZPASS $DOWNTEMP/$DATEDAY/sell_file_index_zzip_province.txt $ZUSER@$ZSITE:$ZDOWNTEMP/sell_file_index.flag >> $SCRIPTDIR/point-FTP.log 2>&1 
#rm -rf $DOWNTEMP/$DATEDAY/33_33003_*_VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1 
rm -rf $DOWNTEMP/$DATEDAY/33_9001*_*_VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1

for i in `ls -1 33_1000*_*_VIP.DAT`
do
    cut -d, -f 1-8  $i >> $DATADIR/$i
    rm -rf $i
done 



################################################## pscp 36_9001*_*_VIP.DAT to ps_jiangxi server ################
echo $DATEDAY > $DOWNTEMP/$DATEDAY/sell_file_index_jxzip_province.txt
ls -1 36_9001*_*_VIP.DAT >>  $DOWNTEMP/$DATEDAY/sell_file_index_jxzip_province.txt
echo "ok" >> $DOWNTEMP/$DATEDAY/sell_file_index_jxzip_province.txt
zip 36_9001x-$DATEDAY.zip 36_9001*_*_VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1
/usr/bin/pscp -l $JXUSER -pw $JXPASS $DOWNTEMP/$DATEDAY/36_9001x-$DATEDAY.zip $JXUSER@$JXSITE:$JXDOWNTEMP >> $SCRIPTDIR/point-FTP.log 2>&1
{ /usr/bin/plink -l $JXUSER -pw $JXPASS $JXUSER@$JXSITE  unzip  $JXDOWNTEMP/36_9001x-$DATEDAY.zip -d $JXDATADIR >> $SCRIPTDIR/point-FTP.log 2>&1 ;}  && /usr/bin/pscp -l $JXUSER -pw $JXPASS $DOWNTEMP/$DATEDAY/sell_file_index_jxzip_province.txt $JXUSER@$JXSITE:$JXDATADIR/sell_file_index.txt >> $SCRIPTDIR/point-FTP.log 2>&1 
#{ /usr/bin/plink -l $JXUSER -pw $JXPASS $JXUSER@$JXSITE  unzip  $JXDOWNTEMP/36_9001x-$DATEDAY.zip -d $JXDATADIR >> $SCRIPTDIR/point-FTP.log 2>&1 ;}  && /usr/bin/pscp -l $JXUSER -pw $JXPASS $DOWNTEMP/$DATEDAY/sell_file_index_jxzip_province.txt $JXUSER@$JXSITE:$JXDOWNTEMP/sell_file_index.txt >> $SCRIPTDIR/point-FTP.log 2>&1 
rm -rf $DOWNTEMP/$DATEDAY/36_9001*_*_VIP.DAT >> $SCRIPTDIR/point-FTP.log 2>&1
rm -rf $DOWNTEMP/$DATEDAY/36_9001x-$DATEDAY.zip


############################################################################################################

mv $DOWNTEMP/$DATEDAY/*_1000*_*_VIP.DAT $DATADIR >> $SCRIPTDIR/point-FTP.log 2>&1

rm -rf $DOWNTEMP/$DATEDAY/zprovince-$DATEDAY.zip
}



###########main program,check downtemp directory#############
echo "------------------------------------------------`date +"%Y-%m-%d_%H:%M:%S"`----------------------------" >> $SCRIPTDIR/point-FTP.log 2>&1
[ ! -d $DOWNTEMP/$DATEDAY ] && { mkdir $DOWNTEMP/$DATEDAY; }

flone="`awk 'NR==1' $DOWNTEMP/sell_file_index.txt`"
###################start run################################

if [ "$flone" == "$DATEDAY" ]
then
    exit 0
else
    creat_list
    down_pointdata
    unzip_pointfile
    check_point_file_miss
    [ -s $DOWNTEMP/error${DATEDAY}.txt ] && /usr/bin/pscp  -l access -pw 'passwd' $DOWNTEMP/error${DATEDAY}.txt access@xxx.xxx.xxx.xxx:/path/error${DATEDAY}.txt >> $SCRIPTDIR/point-FTP.log 2>&1
    copy_data_to_province
    sleep 1
    creat_index_file
fi
echo -e  "------------------------------------------------`date +"%Y-%m-%d_%H:%M:%S"`----------------------------\n\n" >> $SCRIPTDIR/point-FTP.log 2>&1
