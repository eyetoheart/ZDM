#!/bin/sh

#############################################
## file name : QLC.sh
## creator:zhangdm
## create time:2006-05-08
## modify time:2007-03-18
## copyright (C) BeiJing IWT Technology Ltd.
#############################################

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
TABLENAME="table name"

GAME_CODE="10003"              #游戏编码
PROVINCE_CODE="00"             #省码
WINNING_GROUP="01"             #中奖号码组数
LOOPTIME="55"                  #循环间隔时间
WIN_LEVEL=""                   #奖级个数

#IVRSERVERDIR1="/path"
IVRSERVERDIR="/path"
IVR1="xxx.xxx.xxx.xxx"
IVR2="xxx.xxx.xxx.xxx"
IVR3="xxx.xxx.xxx.xxx"
IVR4="xxx.xxx.xxx.xxx"
IVR5="xxx.xxx.xxx.xxx"
IVR6="xxx.xxx.xxx.xxx"

TEMPDIR="/path"

while sleep $LOOPTIME
do
    DATEFORMAT="`date -d '-0 day' "+%Y-%m-%d"`"
    CURRENTISSUE="`awk -F, '$1 ~ /'$GAME_CODE'/ && $3 ~ /'$DATEFORMAT'/ {print $2}' $SCRIPTDIR/point-issue-file.txt`"    #当前期号
    ISSUESTAT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select count(*) from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"    #当前期状态
    BULLFILENAME="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_BULL.DWN"
    NUMBFILENAME="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.DWN"

    NUMBCOLS="base_number,special_number"
    NUMBTEMP="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.TMP"
    NUMBTEMP1="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.TMP.1"    

    BULLCOLS="bet_sum,roll_next,win1_amount,win1_bonus,win2_amount,win2_bonus,win3_amount,win3_bonus,win4_amount,win4_bonus,win5_amount,win5_bonus,win6_amount,win6_bonus,win7_amount,win7_bonus"
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
		BASE_NUMBE="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select base_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}' | sed 's/|//g'`"
		SPECIAL_NUMBER="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select special_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}'`"
		echo -n "$GAME_CODE""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$CURRENTISSUE""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$PROVINCE_CODE""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$WINNING_GROUP""," >> $BAKFILE/$NUMBFILENAME
		echo -n "$BASE_NUMBE""@" >> $BAKFILE/$NUMBFILENAME
		echo -n "$SPECIAL_NUMBER" >> $BAKFILE/$NUMBFILENAME
		echo "create $NUMBFILENAME file completed,now start create currentissue file,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
		echo -n "$CURRENTISSUE" > $BAKFILE/QLC.txt
		echo "now start transfer $NUMBFILENAME file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR5:$IVRSERVERDIR/QLC/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR6:$IVRSERVERDIR/QLC/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$NUMBFILENAME $IVR1:$IVRSERVERDIR/QLC/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$NUMBFILENAME $IVR2:$IVRSERVERDIR/QLC/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR3:$IVRSERVERDIR/QLC/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR4:$IVRSERVERDIR/QLC/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
		echo "now start transfer current issue file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/QLC.txt $IVR5:$IVRSERVERDIR/CurrentIssue/QLC.txt >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/QLC.txt $IVR6:$IVRSERVERDIR/CurrentIssue/QLC.txt >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/QLC.txt $IVR1:$IVRSERVERDIR/CurrentIssue/QLC.txt >> $SCRIPTDIR/logs.txt 2>&1
#		$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/QLC.txt $IVR2:$IVRSERVERDIR/CurrentIssue/QLC.txt >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/QLC.txt $IVR3:$IVRSERVERDIR/CurrentIssue/QLC.txt >> $SCRIPTDIR/logs.txt 2>&1
		$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/QLC.txt $IVR4:$IVRSERVERDIR/CurrentIssue/QLC.txt >> $SCRIPTDIR/logs.txt 2>&1
	fi
	WIN7_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win7_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"
	if [ $WIN7_AMOUNT ]
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
			BET_SUM="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select bet_sum,roll_next from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk -F'[|]' 'NR==3 {print $1","$2}' `"
			echo -n "$BET_SUM""," >> $BAKFILE/$BULLFILENAME
                        WIN8_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win8_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}' `"
                        WIN8_BONUS="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win8_bonus from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"
                        if [[ -n $WIN8_AMOUNT &&  -n $WIN8_BONUS ]]
                        then
                            WIN_LEVEL="08"
                            echo -n "$WIN_LEVEL""," >> $BAKFILE/$BULLFILENAME
                        else
                            WIN_LEVEL="07"
                            echo -n "$WIN_LEVEL""," >> $BAKFILE/$BULLFILENAME
                        fi
			WIN_AMOUNT_BONUS="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win1_amount,win1_bonus,win2_amount,win2_bonus,win3_amount,win3_bonus,win4_amount,win4_bonus,win5_amount,win5_bonus,win6_amount,win6_bonus,win7_amount,win7_bonus from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
			echo -n "$WIN_AMOUNT_BONUS" >> $BAKFILE/$BULLFILENAME
                        if [[ -n  $WIN8_AMOUNT && -n $WIN8_BONUS ]]
                        then
                            echo -n ",""$WIN8_AMOUNT""," >> $BAKFILE/$BULLFILENAME
                            echo -n "$WIN8_BONUS" >> $BAKFILE/$BULLFILENAME
                        fi
			echo "now start transfer $BULLFILENAME file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
                        $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR5:$IVRSERVERDIR/QLC/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                        $PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR6:$IVRSERVERDIR/QLC/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#			$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$BULLFILENAME $IVR1:$IVRSERVERDIR/QLC/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
#			$PSCPDIR/pscp -l administrator -pw 'password' $BAKFILE/$BULLFILENAME $IVR2:$IVRSERVERDIR/QLC/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
			$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR3:$IVRSERVERDIR/QLC/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
			$PSCPDIR/pscp -l iwgroup -pw 'password' $BAKFILE/$BULLFILENAME $IVR4:$IVRSERVERDIR/QLC/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
		fi
        fi

    fi

done
