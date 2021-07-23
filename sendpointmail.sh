#!/bin/sh

SCRIPTDIR="/home/iwgoup/pointmail"
YESTERDAY="`date --date="yesterday" +"%Y-%m-%d"`"
LANG=zh_CN
export LANG
pointdatabakdir="/opt/pointdatabak"

sendmailtouser () { 

cd $SCRIPTDIR
for i in `cat $SCRIPTDIR/receiver.txt`
do
	echo "now start send mail to $i,time is `date +"%H:%M:%S"`" >> $SCRIPTDIR/logs.log
	echo "`cat neirongjieshao.txt`"| mutt -s "`awk 'NR==3 {print $1}' neirongjieshao.txt`" -a $SCRIPTDIR/error${YESTERDAY}.txt $i
done

}
[ -s $SCRIPTDIR/error${YESTERDAY}.txt ] && sendmailtouser


echo "now start backup point data from point calculate server to local" >> $SCRIPTDIR/logs.log
cd $pointdatabakdir
[ ! -d  $YESTERDAY ] && { mkdir $YESTERDAY ; }
pscp -p -l iwgoup -pw 'qX9&L1$l' iwgoup@192.168.61.2:/opt/iwgroup/vasoss/point-calculate-server/downtemp/${YESTERDAY}/*  ./$YESTERDAY >> $SCRIPTDIR/logs.log
cd $pointdatabakdir/$YESTERDAY
ls -1 > $SCRIPTDIR/filelist.txt
if [ -s $SCRIPTDIR/filelist.txt ]
then

	tar cvfz  point_data_${YESTERDAY}.tar.gz ./*.DAT.* >> $SCRIPTDIR/logs.log
	rm  *.DAT.* >> $SCRIPTDIR/logs.log
else

	touch $SCRIPTDIR/error${YESTERDAY}.txt
	echo "all point file not exist" > $SCRIPTDIR/error${YESTERDAY}.txt
	sendmailtouser
fi

rm -f $SCRIPTDIR/filelist.txt

echo "-------------------------------------------------`date +"%Y-%m-%d_%H:%M:%S"`---------------------------------------------------------------" >> $SCRIPTDIR/logs.log
