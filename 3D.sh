#!/bin/sh

SCRIPTDIR="/path"
BAKFILE="/path"
COMMANDDIR="/usr/local/pgsql/bin"
PSCPDIR="/pscp/path"

LANG=zh_CN.GB2312
export LANG

#
#point-issue-file.txt 配置文件的内容如下：
#10002,2016338,2016-12-10
#10001,2016145,2016-12-11
#10002,2016339,2016-12-11
#10003,2016146,2016-12-12
#10002,2016340,2016-12-12
#10001,2016146,2016-12-13
#

DATAHOST="xxx.xxx.xxx.xxx"
DATABASE="database name"
DATABASEPORT="port number"
TABLENAME="tablename"

GAME_CODE="10002"              #游戏编码
PROVINCE_CODE="00"             #省码
WINNING_GROUP="01"             #中奖号码组数
LOOPTIME="50"                  #循环间隔时间
WIN_LEVEL="03"                 #奖级个数
WIN1_BONUS="1000"              #一等奖每注奖金额
WIN2_BONUS="320"               #二等奖每注奖金额
WIN3_BONUS="160"               #三等奖每注奖金额
ROLL_NEXT="0"                  #本期奖池期末余额

#IVRSERVERDIR1="/path"
IVRSERVERDIR="/path"
IVR1="xxx.xxx.xxx.xxx"
IVR2="xxx.xxx.xxx.xxx"
IVR3="xxx.xxx.xxx.xxx"
IVR4="xxx.xxx.xxx.xxx"
IVR5="xxx.xxx.xxx.xxx"
IVR6="xxx.xxx.xxx.xxx"

TEMPDIR="/path/tmp"

while sleep $LOOPTIME
do
    DATEFORMAT="`date -d '-0 day' "+%Y-%m-%d"`"
    DATEFORMAT1="`date -d '-0 day' "+%Y%m%d"`"
    CURRENTISSUE="`awk -F, '$1 ~ /'$GAME_CODE'/ && $3 ~ /'$DATEFORMAT'/ {print $2}' $SCRIPTDIR/point-issue-file.txt`"    #当前期号
    ISSUESTAT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select count(*) from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"    #当前期状态
    BULLFILENAME="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_BULL.DWN"
    NUMBFILENAME="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.DWN"

    NUMBCOLS="win_number"
    NUMBTEMP="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.TMP"
    NUMBTEMP1="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.TMP.1"    

    BULLCOLS="bet_sum,win1_amount,win2_amount,win3_amount"
    BULLTEMP="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_BULL.TMP"
    BULLTEMP1="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_BULL.TMP.1" 
    
    if [ $ISSUESTAT -eq 1 ]
    then
        echo "game $GAME_CODE already Lottery,time is `date +"%Y-%m-%d_%H:%M:%S"`---------------------------------------------" >> $SCRIPTDIR/logs.txt

	if [ ! -s $TEMPDIR/$NUMBTEMP ]
        then
                $COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $NUMBCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print}' >$TEMPDIR/$NUMBTEMP
        else
                $COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $NUMBCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print}' >$TEMPDIR/$NUMBTEMP1
                NUMBMODSTAT="`diff $TEMPDIR/$NUMBTEMP $TEMPDIR/$NUMBTEMP1 | wc -l`"
                if [ $NUMBMODSTAT -gt 0 ]
                then
                        rm -rf $BAKFILE/$NUMBFILENAME;
                        rm -rf $TEMPDIR/$NUMBTEMP;
                        mv $TEMPDIR/$NUMBTEMP1 $TEMPDIR/$NUMBTEMP;
                fi
        fi

	if [ ! -s $BAKFILE/$NUMBFILENAME ]
	then
		echo "now start create $NUMBFILENAME file,time is `date +"%Y-%m-%d_%H:%M:%S"`..."  >> $SCRIPTDIR/logs.txt
		WIN_NUMBER="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}' | awk 'BEGIN{FS=""} {print $1"+"$2"+"$3}'`"
		echo -n "$GAME_CODE""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$CURRENTISSUE""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$PROVINCE_CODE""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$WINNING_GROUP""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$WIN_NUMBER" >> $BAKFILE/$NUMBFILENAME
		echo "create $NUMBFILENAME file completed,now start create currentissue file,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
		echo -n "$CURRENTISSUE" > $BAKFILE/3D.txt
		echo "now start transfer $NUMBFILENAME file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR5:$IVRSERVERDIR/3D/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR5:$IVRSERVERDIR/3D/${DATEFORMAT1}_NUMB.DWN >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR6:$IVRSERVERDIR/3D/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR6:$IVRSERVERDIR/3D/${DATEFORMAT1}_NUMB.DWN >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$NUMBFILENAME $IVR1:$IVRSERVERDIR/3D/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$NUMBFILENAME $IVR1:$IVRSERVERDIR/3D/${DATEFORMAT1}_NUMB.DWN >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$NUMBFILENAME $IVR2:$IVRSERVERDIR/3D/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$NUMBFILENAME $IVR2:$IVRSERVERDIR/3D/${DATEFORMAT1}_NUMB.DWN >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR3:$IVRSERVERDIR/3D/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR3:$IVRSERVERDIR/3D/${DATEFORMAT1}_NUMB.DWN >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR4:$IVRSERVERDIR/3D/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR4:$IVRSERVERDIR/3D/${DATEFORMAT1}_NUMB.DWN >> $SCRIPTDIR/logs.txt 2>&1
		echo "now start transfer current issue file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/3D.txt $IVR5:$IVRSERVERDIR/CurrentIssue/3D.txt >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/3D.txt $IVR6:$IVRSERVERDIR/CurrentIssue/3D.txt >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/3D.txt $IVR1:$IVRSERVERDIR/CurrentIssue/3D.txt >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/3D.txt $IVR2:$IVRSERVERDIR/CurrentIssue/3D.txt >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/3D.txt $IVR3:$IVRSERVERDIR/CurrentIssue/3D.txt >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/3D.txt $IVR4:$IVRSERVERDIR/CurrentIssue/3D.txt >> $SCRIPTDIR/logs.txt 2>&1
	fi

	WIN1_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win1_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"
	if [ $WIN1_AMOUNT ]
	then

		if [ ! -s $TEMPDIR/$BULLTEMP ]
		then
			$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $BULLCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print}' >$TEMPDIR/$BULLTEMP
		else
			$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $BULLCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print}' >$TEMPDIR/$BULLTEMP1
			BULLMODSTAT="`diff $TEMPDIR/$BULLTEMP $TEMPDIR/$BULLTEMP1 | wc -l`"
			if [ $BULLMODSTAT -gt 0 ]
			then
				rm -rf $BAKFILE/$BULLFILENAME;
				rm -rf $TEMPDIR/$BULLTEMP;
				mv $TEMPDIR/$BULLTEMP1 $TEMPDIR/$BULLTEMP;
			fi
		fi

		if [ ! -s $BAKFILE/$BULLFILENAME ]
		then
			echo "Not yet creat $BULLFILENAME file,Look at $NUMBFILENAME file exist or not" >> $SCRIPTDIR/logs.txt
			cp $BAKFILE/$NUMBFILENAME $BAKFILE/$BULLFILENAME
			echo -n "," >> $BAKFILE/$BULLFILENAME
			BET_SUM="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select bet_sum from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"
			echo -n "$BET_SUM""," >> $BAKFILE/$BULLFILENAME
			echo -n "$ROLL_NEXT""," >> $BAKFILE/$BULLFILENAME
			echo -n "$WIN_LEVEL""," >> $BAKFILE/$BULLFILENAME
			WIN2_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win2_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"
			WIN3_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win3_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"
			echo -n "$WIN1_AMOUNT""," >> $BAKFILE/$BULLFILENAME
			echo -n "$WIN1_BONUS""," >> $BAKFILE/$BULLFILENAME
			echo -n "$WIN2_AMOUNT""," >> $BAKFILE/$BULLFILENAME
			echo -n "$WIN2_BONUS""," >> $BAKFILE/$BULLFILENAME
			echo -n "$WIN3_AMOUNT""," >> $BAKFILE/$BULLFILENAME
			echo -n "$WIN3_BONUS" >> $BAKFILE/$BULLFILENAME
			echo "now start transfer $BULLFILENAME file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
                        $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR5:$IVRSERVERDIR/3D/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                        $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR5:$IVRSERVERDIR/3D/${DATEFORMAT1}_BULL.DWN >> $SCRIPTDIR/logs.txt 2>&1
                        $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR6:$IVRSERVERDIR/3D/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                        $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR6:$IVRSERVERDIR/3D/${DATEFORMAT1}_BULL.DWN >> $SCRIPTDIR/logs.txt 2>&1
#			$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$BULLFILENAME $IVR1:$IVRSERVERDIR/3D/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#			$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$BULLFILENAME $IVR1:$IVRSERVERDIR/3D/${DATEFORMAT1}_BULL.DWN >> $SCRIPTDIR/logs.txt 2>&1
#			$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$BULLFILENAME $IVR2:$IVRSERVERDIR/3D/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#			$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$BULLFILENAME $IVR2:$IVRSERVERDIR/3D/${DATEFORMAT1}_BULL.DWN >> $SCRIPTDIR/logs.txt 2>&1
			$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR3:$IVRSERVERDIR/3D/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
			$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR3:$IVRSERVERDIR/3D/${DATEFORMAT1}_BULL.DWN >> $SCRIPTDIR/logs.txt 2>&1
			$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR4:$IVRSERVERDIR/3D/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
			$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR4:$IVRSERVERDIR/3D/${DATEFORMAT1}_BULL.DWN >> $SCRIPTDIR/logs.txt 2>&1
		fi

        fi

    fi

done
