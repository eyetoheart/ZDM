#!/bin/sh

##########**********Define Envionment Variables**********##########

SCRIPTDIR="/path"
BACKUPDIR="/path/databak"
CONFIGFILE="/path/manual.txt"
servername=`echo $HOSTNAME | awk -F. '{print $1}'`

##########**********define date Format**********###########
TODAYDATE="`date "+%Y%m%d%H"`"
TODAYDATEFULL="`date "+%Y-%m-%d_%H:%M:%S"`"

##########**********Print The Select Menu**********##########
echo

awk 'NR == 1' $SCRIPTDIR/word.txt

echo

configfilelinenumber="`wc -l $CONFIGFILE | awk '{print $1}'`"
awk '{print NR,":",$0}' $CONFIGFILE
echo
echo -e "Please select one from 1 to `wc -l $CONFIGFILE | awk '{print $1}'`, or input the path: \c"
read  dirpath
/usr/bin/seq 1 $configfilelinenumber | grep $dirpath > /dev/null 2>&1
if  [ $? -eq 0 ]
then
    echo -e "now start backup directory `awk 'NR == '$dirpath'' $CONFIGFILE`,be sure of this diretory is you need backup:([Y/y] or [N/n])\c"
    read YORN
    if [ "$YORN" = "Y" -o "$YORN" = "y" ]
    then
        echo "execute backup program ..."
        filename=${servername}"`awk 'NR == '$dirpath'' $CONFIGFILE | sed 's/\//_/g'`"_${TODAYDATE}.tar
        cd `awk 'NR == '$dirpath'' $CONFIGFILE`
        tar cvf ${filename} ./* > /dev/null 2>&1
        gzip ${filename} >> $SCRIPTDIR/manual.log 2>&1
	mv ${filename}.gz $BACKUPDIR
        echo "already backup `awk 'NR == '$dirpath'' $CONFIGFILE` directory to $BACKUPDIR directory,backup file name is ${filename}.gz"
        echo "at the $TODAYDATEFULL,you backup `awk 'NR == '$dirpath'' $CONFIGFILE` directory to $BACKUPDIR directory,backup file name is ${filename}.gz" >> $SCRIPTDIR/manual.log
        echo >> $SCRIPTDIR/manual.log
    else
        echo "please you select again"
        echo "at the $TODAYDATEFULL,you ever select $dirpath,but you canceled this operate" >> $SCRIPTDIR/manual.log
        echo >> $SCRIPTDIR/manual.log
    fi

else
    echo -e "You not select number,but you input the path,please you be sure of this diretory exist:([Y/y] or [N/n])\c"
    read YORN
    if [ "$YORN" = "Y" -o "$YORN" = "y" ]
    then
        if [ -d $dirpath ]
        then
            echo "execute backup program ..."
            filename="${servername}""`echo $dirpath | sed 's/\//_/g'`"_${TODAYDATE}.tar
            cd $dirpath
            tar cvf ${filename} ./* > /dev/null 2>&1
            gzip ${filename} >> $SCRIPTDIR/manual.log 2>&1
            mv ${filename}.gz $BACKUPDIR
            echo "already backup $dirpath directory to $BACKUPDIR directory,backup file name is ${filename}.gz"
            echo "at the $TODAYDATEFULL,you backup $dirpath directory to $BACKUPDIR directory,backup file name is ${filename}.gz" >> $SCRIPTDIR/manual.log
            echo >> $SCRIPTDIR/manual.log
        else
            awk 'NR == 2' $SCRIPTDIR/word.txt
            #echo "you input path not exist,please check and input again"
            echo "at the $TODAYDATEFULL,you input the path of you need backup,but this directory is not exist" >> $SCRIPTDIR/manual.log
            echo >> $SCRIPTDIR/manual.log
        fi
    else
        echo "please you select again"
        echo "at the $TODAYDATEFULL,you input the path of you need backup,but this operate be canceled by you" >> $SCRIPTDIR/manual.log
        echo >> $SCRIPTDIR/manual.log
    fi
fi
