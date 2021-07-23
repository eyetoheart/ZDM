#!/bin/sh

SCRIPTDIR="/path"
BAKFILE="/path"
TEMPDIR="/path"
COMMANDDIR="/usr/local/pgsql/bin"   #postgres 数据库命令所在路径
PSCPDIR="/usr/bin"  #pscp命令所在路径

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

GAME_CODE="10001"              #游戏编码
PROVINCE_CODE="00"             #省码
WINNING_GROUP="01"             #中奖号码组数
LOOPTIME="45"                  #循环间隔时间
WIN_LEVEL=""                   #奖级个数
#######如果存在快乐星期天奖则将程序内有关SUNDAY_BALL变量前面的注释去掉

IVRSERVERDIR="/path"
IVR3="xxx.xxx.xxx.xxx"
IVR4="xxx.xxx.xxx.xxx"
IVR5="xxx.xxx.xxx.xxx"
IVR6="xxx.xxx.xxx.xxx"

while sleep $LOOPTIME
do
    DATEFORMAT="`date -d '-0 day' "+%Y-%m-%d"`"
    CURRENTISSUE="`awk -F, '$1 ~ /'$GAME_CODE'/ && $3 ~ /'$DATEFORMAT'/ {print $2}' $SCRIPTDIR/point-issue-file.txt`"    #当前期号
    ISSUESTAT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select count(*) from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"    #当前期状态
    BULLFILENAME="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_BULL.DWN"
    NUMBFILENAME="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.DWN"
    
    NUMBCOLS="red_win_number,blue_win_number,sunday_win_number,lucky_blue_win_number"
    NUMBTEMP="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.TMP"
    NUMBTEMP1="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_NUMB.TMP.1"    

    BULLCOLS="bet_sum,red_win_number,blue_win_number,sunday_win_number,lucky_blue_win_number,roll_next,win1_amount,win1_bonus,added_win1_amount,win2_amount,win2_bonus,win3_amount,win3_bonus,win4_amount,win4_bonus,win5_amount,win5_bonus,win6_amount,win6_bonus,win8_amount,win8_bonus,win9_amount,win9_bonus"
    BULLTEMP="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_BULL.TMP"
    BULLTEMP1="${PROVINCE_CODE}_${GAME_CODE}_${CURRENTISSUE}_BULL.TMP.1" 

    if [ $ISSUESTAT -eq 1 ]
    then
        echo "game $GAME_CODE already Lottery,time is `date +"%Y-%m-%d_%H:%M:%S"`---------------------------------------------" >> $SCRIPTDIR/logs.txt

        if [ ! -s $TEMPDIR/$NUMBTEMP ]
        then
            $COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $NUMBCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/ /g' | sed 's/ //g' > $TEMPDIR/$NUMBTEMP
        else
            $COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $NUMBCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/ /g' | sed 's/ //g' > $TEMPDIR/$NUMBTEMP1
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
            RED_BALL="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select red_win_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}' | sed 's/|//g'`"
            BLUE_BALL="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select blue_win_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}'`"
            SUNDAY_BALL="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select sunday_win_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}'`"
            LUCKY_BLUE_BALL="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select lucky_blue_win_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}'`"
            echo -n "$GAME_CODE""," >> $BAKFILE/$NUMBFILENAME
            echo -n "$CURRENTISSUE""," >> $BAKFILE/$NUMBFILENAME
            echo -n "$PROVINCE_CODE""," >> $BAKFILE/$NUMBFILENAME
            echo -n "$WINNING_GROUP""," >> $BAKFILE/$NUMBFILENAME
            echo -n "$RED_BALL""+" >> $BAKFILE/$NUMBFILENAME
            echo -n "$BLUE_BALL" >> $BAKFILE/$NUMBFILENAME
            if [ $SUNDAY_BALL ]
            then
                echo -n "@""$SUNDAY_BALL" >> $BAKFILE/$NUMBFILENAME
            fi
            if [ $LUCKY_BLUE_BALL ]
            then
                echo -n "|""$LUCKY_BLUE_BALL" >> $BAKFILE/$NUMBFILENAME
            fi   

            echo "create $NUMBFILENAME file completed,now start create currentissue file,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
            echo -n "$CURRENTISSUE" > $BAKFILE/SSQ.txt
            echo "now start transfer $NUMBFILENAME file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR3:$IVRSERVERDIR/SSQ/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR4:$IVRSERVERDIR/SSQ/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR5:$IVRSERVERDIR/SSQ/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$NUMBFILENAME $IVR6:$IVRSERVERDIR/SSQ/$NUMBFILENAME >> $SCRIPTDIR/logs.txt 2>&1
            echo "now start transfer current issue file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/SSQ.txt $IVR3:$IVRSERVERDIR/CurrentIssue/SSQ.txt >> $SCRIPTDIR/logs.txt 2>&1
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/SSQ.txt $IVR4:$IVRSERVERDIR/CurrentIssue/SSQ.txt >> $SCRIPTDIR/logs.txt 2>&1
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/SSQ.txt $IVR5:$IVRSERVERDIR/CurrentIssue/SSQ.txt >> $SCRIPTDIR/logs.txt 2>&1
            $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/SSQ.txt $IVR6:$IVRSERVERDIR/CurrentIssue/SSQ.txt >> $SCRIPTDIR/logs.txt 2>&1
        fi

        WIN6_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win6_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}'`"
        if [ $WIN6_AMOUNT ]
        then
            if [ ! -s $TEMPDIR/$BULLTEMP ]
            then
                $COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $BULLCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|//g' | sed 's/ //g' > $TEMPDIR/$BULLTEMP
            else
                $COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select $BULLCOLS from $TABLENAME  where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|//g' | sed 's/ //g' > $TEMPDIR/$BULLTEMP1
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
                LUCKY_BLUE_BALL="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select lucky_blue_win_number from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3{print $1}'`"
                echo -n "," >> $BAKFILE/$BULLFILENAME
                BET_SUM="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select bet_sum,roll_next from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk -F'[|]' 'NR==3 {print $1","$2}' `"
                echo -n "$BET_SUM""," >> $BAKFILE/$BULLFILENAME
                WIN8_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win8_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
                WIN8_BONUS="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win8_bonus from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
                WIN9_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win9_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
                WIN9_BONUS="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win9_bonus from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
                if [[ -n $WIN8_AMOUNT || -n  $WIN9_AMOUNT ]]
                then
                    WIN_LEVEL="09"
                    echo -n "$WIN_LEVEL""," >> $BAKFILE/$BULLFILENAME
                else
                    WIN_LEVEL="06"
                    echo -n "$WIN_LEVEL""," >> $BAKFILE/$BULLFILENAME
                fi
                WIN1_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win1_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
                WIN1_BONUS="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win1_bonus from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
#                ADDED_WIN1_AMOUNT="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select added_win1_amount from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3 {print $1}' | sed 's/|/,/g'`"
                echo -n "$WIN1_AMOUNT""," >> $BAKFILE/$BULLFILENAME
                echo -n "$WIN1_BONUS" >> $BAKFILE/$BULLFILENAME
#                if [[ $ADDED_WIN1_AMOUNT && $ADDED_WIN1_AMOUNT -ne 0 ]]
#                then
#                    echo -n "|""$ADDED_WIN1_AMOUNT" >> $BAKFILE/$BULLFILENAME
#                fi
                WIN_AMOUNT_BONUS="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win2_amount,win2_bonus,win3_amount,win3_bonus,win4_amount,win4_bonus,win5_amount,win5_bonus,win6_amount,win6_bonus from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
                echo -n ",""$WIN_AMOUNT_BONUS" >> $BAKFILE/$BULLFILENAME
#                LUCKY_AMOUNT_BONUS="`$COMMANDDIR/psql -h $DATAHOST -p $DATABASEPORT -d $DATABASE -c "select win8_amount,win8_bonus from $TABLENAME where issue_number = '$CURRENTISSUE'" | awk 'NR==3' | sed 's/|/,/g'`"
#                if [ $LUCKY_BLUE_BALL ]
#                then
#                    echo -n ",""$LUCKY_AMOUNT_BONUS" >> $BAKFILE/$BULLFILENAME
#                fi
                if [  $WIN8_AMOUNT ]
                then
                    echo -n ",0,0,""$WIN8_AMOUNT"",""$WIN8_BONUS" >> $BAKFILE/$BULLFILENAME
                    if [ $WIN9_AMOUNT ]
                    then
                        echo -n ",""$WIN9_AMOUNT"",""$WIN9_BONUS" >> $BAKFILE/$BULLFILENAME
                    else
                        echo -n ",0,0" >> $BAKFILE/$BULLFILENAME
                    fi
                else
                    if [ $WIN9_AMOUNT ]
                    then
                        echo -n ",0,0,0,0,""$WIN9_AMOUNT"",""$WIN9_BONUS" >> $BAKFILE/$BULLFILENAME
                    fi
                fi
                echo "now start transfer $BULLFILENAME file to IVR,time is `date +"%Y-%m-%d_%H:%M:%S"`..." >> $SCRIPTDIR/logs.txt
                $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$BULLFILENAME $IVR3:$IVRSERVERDIR/SSQ/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$BULLFILENAME $IVR4:$IVRSERVERDIR/SSQ/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$BULLFILENAME $IVR5:$IVRSERVERDIR/SSQ/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
                $PSCPDIR/pscp -l iwgoup -pw 'password' $BAKFILE/$BULLFILENAME $IVR6:$IVRSERVERDIR/SSQ/$BULLFILENAME >> $SCRIPTDIR/logs.txt 2>&1
            fi
        fi
    fi
done
