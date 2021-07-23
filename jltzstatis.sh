#!/bin/sh

SCRIPTDIR="/opt/jltzstatis/bin"
DATADIR="/opt/jltzstatis/data"
CDRDIR="/opt/jltzstatis/cdrbak"

awk -F '[ -:]' '{print $1","$3$4$5$6$7$8}' $CDRDIR/96100bill.txt > $CDRDIR/96100bill1.txt
awk -F '[ -,:]' '{print $1","$2$3$4$5$6$7","$8$9$10$11$12$13}' $CDRDIR/zhibing.txt > $CDRDIR/zhibing1.txt

touch $DATADIR/zuizhong1.txt
touch $DATADIR/nojieguo1.txt
for i in `cat $CDRDIR/zhibing1.txt`
do
	zb1y=`echo $i | awk -F '[,]' '{print $1}'`
	zb2y=`echo $i | awk -F '[,]' '{print $2}'`
	zb3y=`echo $i | awk -F '[,]' '{print $3}'`
	grep "$zb1y" $CDRDIR/96100bill1.txt > $CDRDIR/tempzdm.txt
	if [ $? -eq 0 ]
	then
		for j in `cat $CDRDIR/tempzdm.txt`
		do
			cdr2y=`echo $j | awk -F '[,]' '{print $2}'`
			if [ "$zb3y" -lt "$cdr2y" ]
			then
				grep "$zb1y" $DATADIR/zuizhong1.txt >> $SCRIPTDIR/log.txt 2>&1
				[ $? -ne 0 ] && echo "$zb1y,$zb2y,$zb3y,$cdr2y" >> $DATADIR/zuizhong1.txt
			fi
		done
	fi
done


for i in `cat $CDRDIR/zhibing1.txt`
do
	zhibmobile=`echo $i | awk -F '[,]' '{print $1}'`
	grep "$zhibmobile" $DATADIR/zuizhong1.txt >> $SCRIPTDIR/log.txt 2>&1
	[ $? -ne 0 ] && echo $i >> $DATADIR/nojieguo1.txt
done

for i in `cat $DATADIR/zuizhong1.txt`
do
	zuiz1=`echo $i | awk -F '[,]' '{print $1}'`
	zuiz2=`echo $i | awk -F '[,]' '{print $2}' | sed -r 's/^(.{4})(.{2})(.{2})(.{2})(.{2})(.{2})$/\1-\2-\3 \4:\5:\6/g'`
	zuiz3=`echo $i | awk -F '[,]' '{print $3}' | sed -r 's/^(.{4})(.{2})(.{2})(.{2})(.{2})(.{2})$/\1-\2-\3 \4:\5:\6/g'`
	zuiz4=`echo $i | awk -F '[,]' '{print $4}' | sed -r 's/^(.{4})(.{2})(.{2})(.{2})(.{2})(.{2})$/\1-\2-\3 \4:\5:\6/g'`
	echo "$zuiz1,$zuiz2,$zuiz3,$zuiz4" >> $DATADIR/zuizhong_yewu.txt
	echo "$zuiz1,$zuiz3,$zuiz4" >> $DATADIR/zuizhong_jishu.txt
done
for i in `cat $DATADIR/nojieguo1.txt`
do
	nojieguo1=`echo $i | awk -F '[,]' '{print $1}'`
	nojieguo2=`echo $i | awk -F '[,]' '{print $2}' | sed -r 's/^(.{4})(.{2})(.{2})(.{2})(.{2})(.{2})$/\1-\2-\3 \4:\5:\6/g'`
	nojieguo3=`echo $i | awk -F '[,]' '{print $3}' | sed -r 's/^(.{4})(.{2})(.{2})(.{2})(.{2})(.{2})$/\1-\2-\3 \4:\5:\6/g'`
	echo "$nojieguo1,$nojieguo2,$nojieguo3" >> $DATADIR/nojieguo.txt
done

rm -f $CDRDIR/96100bill1.txt
rm -f $DATADIR/nojieguo1.txt
rm -f $DATADIR/zuizhong1.txt
rm -f $CDRDIR/zhibing1.txt
