#!/bin/sh
#####################################################
## file name : scanup_export.sh
## creator:zhangdm
## create time:2017-06-02
## modify time:2017-06-03
## copyright (C) Innovative World Technology Co.,Ltd.
#####################################################

###################Define Envionment Variables########
LANG=zh_CN.UTF-8
export LANG
SCRIPTDIR="/home/postgres/backup/script/scanup_export"
BUSIFILE="/opt/iwgroup/vasoss4.1/prvnpoint/scanReport/file"
BUSIFLAG="/opt/iwgroup/vasoss4.1/prvnpoint/scanReport/flag"

#BUSIFILE="/home/postgres/backup/script/scanup_export/file"
#BUSIFLAG="/home/postgres/backup/script/scanup_export/flag"

DATEFORMAT1="`date -d '-0 day' "+%Y-%m-%d"`"
DATEFORMAT2="`date -d '-0 day' "+%Y%m%d"`"
YESTERDAY="`date -d '-1 day' "+%Y%m%d"`"
TIMEFORMAT="`date -d '-0 day' "+%H%M"`"

DATABASEHOST="192.168.68.7"
DATABASENAME="province_point"
DATABASEPORT="8765"

scanup_check () {

/usr/local/pgsql/bin/psql  -h $DATABASEHOST -p $DATABASEPORT -d $DATABASENAME -c "SELECT max (issue_number) FROM report_issue_t r LEFT JOIN sys_province_t s ON r.sys_province_oid = s.iwoid WHERE r.game_code = '${1}' AND s.province_code = '${2}' AND r.report_date = '${3}' AND r.scan_end_time <= now();" | sed '1,2d' | sed '$d' | sed '$d' | awk '{print $1}'

}

scanup_export () {

/usr/local/pgsql/bin/psql  -h $DATABASEHOST -p $DATABASEPORT -d $DATABASENAME -c "SELECT srd.card_no, srd.scan_code, srd.lottery_scan_oid FROM scan_report_detail_t srd WHERE EXISTS ( SELECT 1 FROM scan_report_t srt WHERE srt.iwoid = srd.scan_report_oid AND srt.status = 1 AND srt.game_code ='${1}' AND srt.province_code = '${2}' AND srt.report_date = '${3}' );" | sed '1,2d' | sed '$d' | sed '$d' | sed 's/|/,/g' | sed 's/ //g'

}

scanup_export_hn () {

/usr/local/pgsql/bin/psql  -h $DATABASEHOST -p $DATABASEPORT -d $DATABASENAME -c "SELECT srd.card_no, split_part(srd.scan_code,'tickets=',2), srd.lottery_scan_oid FROM scan_report_detail_t srd WHERE EXISTS ( SELECT 1 FROM scan_report_t srt WHERE srt.iwoid = srd.scan_report_oid AND srt.status = 1 AND srt.game_code ='${1}' AND srt.province_code = '${2}' AND srt.report_date = '${3}' );" | sed '1,2d' | sed '$d' | sed '$d' | sed 's/|/,/g' | sed 's/ //g'

}

echo "------------------`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`-------------------------------------" >> $SCRIPTDIR/logs.log
case  $TIMEFORMAT in
0040)
    VALUE="`scanup_check 33004 33 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该33004玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 33 33004 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export  33004 33 $DATEFORMAT1 >  $BUSIFILE/33_33004_${YESTERDAY}.txt
    [ -f $BUSIFILE/33_33004_${YESTERDAY}.txt ] && { echo "ok" > $BUSIFLAG/33_33004_${YESTERDAY}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

1920)
    VALUE="`scanup_check 90015 33 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该90015玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 33 90015 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export  90015 33 $DATEFORMAT1 >  $BUSIFILE/33_90015_${VALUE}.txt
    [ -f $BUSIFILE/33_90015_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/33_90015_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2020)
    VALUE="`scanup_check 90016 33 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该90016玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 33 90016 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export  90016 33 $DATEFORMAT1 >  $BUSIFILE/33_90016_${VALUE}.txt
    [ -f $BUSIFILE/33_90016_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/33_90016_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2131)
    VALUE="`scanup_check 10002 41 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该10002玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 41 10002 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export_hn  10002 41 $DATEFORMAT1 >  $BUSIFILE/41_10002_${VALUE}.txt
    [ -f $BUSIFILE/41_10002_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/41_10002_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2136)
    VALUE="`scanup_check 41001 41 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该10002玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 41 41001 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export_hn  41001 41 $DATEFORMAT1 >  $BUSIFILE/41_41001_${VALUE}.txt
    [ -f $BUSIFILE/41_41001_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/41_41001_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2142)
    VALUE="`scanup_check 10003 41 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该10003玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 41 10003 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export_hn  10003 41 $DATEFORMAT1 >  $BUSIFILE/41_10003_${VALUE}.txt
    [ -f $BUSIFILE/41_10003_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/41_10003_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2145)
    VALUE="`scanup_check 10002 33 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该10002玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 33 10002 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export  10002 33 $DATEFORMAT1 >  $BUSIFILE/33_10002_${VALUE}.txt
    [ -f $BUSIFILE/33_10002_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/33_10002_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2146)
    VALUE="`scanup_check 10001 41 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该10001玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 41 10001 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export_hn  10001 41 $DATEFORMAT1 >  $BUSIFILE/41_10001_${VALUE}.txt
    [ -f $BUSIFILE/41_10001_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/41_10001_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2150)
    VALUE="`scanup_check 10003 33 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该10003玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 33 10003 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export  10003 33 $DATEFORMAT1 >  $BUSIFILE/33_10003_${VALUE}.txt
    [ -f $BUSIFILE/33_10003_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/33_10003_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2200)
    VALUE="`scanup_check 10001 33 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该10001玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 33 10001 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export  10001 33 $DATEFORMAT1 >  $BUSIFILE/33_10001_${VALUE}.txt
    [ -f $BUSIFILE/33_10001_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/33_10001_${VALUE}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

2250)
    VALUE="`scanup_check 33003 33 $DATEFORMAT1`"
    [ ! $VALUE ] &&  { echo "期号为空,可能该33003玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
    echo "start export 33 33003 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    scanup_export  33003 33 $DATEFORMAT1 >  $BUSIFILE/33_33003_${DATEFORMAT2}.txt
    [ -f $BUSIFILE/33_33003_${DATEFORMAT2}.txt ] && { echo "ok" > $BUSIFLAG/33_33003_${DATEFORMAT2}_flag.txt ; }
    echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
    ;;

*)
    GAME_CODE=$1
    PRO_CODE=$2
    REP_DATE=$3
    if [[ $GAME_CODE && $PRO_CODE && $REP_DATE  ]]
    then
        VALUE="`scanup_check   $GAME_CODE  $PRO_CODE  $REP_DATE`"
        [ ! $VALUE ] &&  { echo "期号为空,可能该$GAME_CODE玩法今天无期结" >> $SCRIPTDIR/logs.log ; exit 0 ; }
        if [[ $GAME_CODE == 33003 ]]
        then
            echo "start export $PRO_CODE 33003 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
            scanup_export  33003 33 $REP_DATE >  $BUSIFILE/33_33003_${REP_DATE}.txt
            [ -f $BUSIFILE/33_33003_${REP_DATE}.txt ] && { echo "ok" > $BUSIFLAG/33_33003_${REP_DATE}_flag.txt ; }
            echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
        elif [[ $GAME_CODE == 33004 ]]
        then
            echo "start export $PRO_CODE 33004 game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
            REP_DATE1="`date -d ''$REP_DATE' -1 day' +%Y%m%d`"
            scanup_export  33004 33 $REP_DATE >  $BUSIFILE/33_33004_${REP_DATE1}.txt
            [ -f $BUSIFILE/33_33004_${REP_DATE1}.txt ] && { echo "ok" > $BUSIFLAG/33_33004_${REP_DATE1}_flag.txt ; }
            echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
        elif [[ $PRO_CODE == 41 ]]
        then
            echo "start export $PRO_CODE $GAME_CODE game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
            scanup_export_hn  $GAME_CODE $PRO_CODE $REP_DATE >  $BUSIFILE/${PRO_CODE}_${GAME_CODE}_${VALUE}.txt
            [ -f $BUSIFILE/${PRO_CODE}_${GAME_CODE}_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/${PRO_CODE}_${GAME_CODE}_${VALUE}_flag.txt ; }
            echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
        else
            echo "start export $PRO_CODE $GAME_CODE game scan file:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
            scanup_export  $GAME_CODE $PRO_CODE $REP_DATE >  $BUSIFILE/${PRO_CODE}_${GAME_CODE}_${VALUE}.txt
            [ -f $BUSIFILE/${PRO_CODE}_${GAME_CODE}_${VALUE}.txt ] && { echo "ok" > $BUSIFLAG/${PRO_CODE}_${GAME_CODE}_${VALUE}_flag.txt ; }
            echo "end export:`date -d '-0 day' "+%Y-%m-%d_%H:%M:%S"`" >> $SCRIPTDIR/logs.log
        fi
    else
        echo "浙江33004导出时间：00:40:00"
        echo "浙江90015导出时间：19:20:00"
        echo "浙江90016导出时间：20:20:00"
        echo "河南10002导出时间：21:31:00"
        echo "河南41001导出时间：21:36:00"
        echo "河南10003导出时间：21:42:00"
        echo "河南10001导出时间：21:46:00"
        echo "浙江10002导出时间：21:45:00"
        echo "浙江10003导出时间：21:50:00"
        echo "浙江10001导出时间：22:00:00"
        echo "浙江33003导出时间：22:50:00"
        echo "您在非上述时间点执行了该脚本,所以无任何数据导出"
        echo "如果您需要使用该脚本手工导出相关数据,请在执行该脚本时按顺序给出三个参数:玩法代码 省码 日期,如下所示:"
        echo "./scanup_export.sh  10002  33  20170603"
    fi
    ;;
esac
