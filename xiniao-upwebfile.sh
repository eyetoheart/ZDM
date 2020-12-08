      喜鸟官网FTP server搭建完成，用于日常更新网站页面上传文件，FTP Server的登录信息如下：
      FTP服务器：xxx.xxx.xxx.xxx
      登录账号名：upfile
      登录密码：sdfasfsad

      为了便于今后频繁编辑页面文件自动更新到生产环境，我写了一个脚本完成此工作，以下是此脚本部署及使用说明，同时也对上传文件的要求做了说明：
      1.脚本部署说明：喜鸟官网xxx.xxx.xxx.xxx服务器的/root/script/upwebfile.sh；
      2.登录上述FTP Server后看到两个目录：mobile（喜鸟官网移动版）、pc（喜鸟官网PC版），分别用于上传不同版的文件；
      3.考虑到所修改文件的多少不同，此脚本支持处理多个页面文件的上传，同时支持整站压文件处理：
            3.1.修改的页面不多时，可以按照文件所在目录上传到FTP Server，例如：更新了pc版的 /src/index.html文件，上传文件时按照/src/index.html目录结构上传到FTP Server的pc目录下；
            3.2.支持新增文件夹及文件上传，只要按照上述规则目录结构上传即可，例如：/src/目下新增/test/test.html，上传文件时按照/src/test/test.html目录结构上传即可；
            3.3.更新的页面较多时，支持整站打成压缩包上传，压缩文件名不限，压缩格式必须为.zip或.ZIP文件，上传到对应版的根目录下即可，例如：将PC版整站文件压缩成PC.zip文件，上传到FTP Server的pc目录下即可，需注意的是，压缩包必须是整站文件，并且压缩文件为网站文件的根路径，即打开PC.zip压缩包后即是css、img、js、src等目录；
      4.脚本执行时首先备份被更新的文件，备份文件存放在/home/upfile/backup目录下；
      5.脚本执行过程中产生的日志文件存放位置：/root/script/logs.log；
      6.脚本放在定时任务中，每5分钟执行一次；


#!/bin/sh

scriptdir="/root/script"
backupdir="/home/upfile/backup"
ftppcdir="/home/upfile/upfiledir/pc"
ftpmobiledir="/home/upfile/upfiledir/mobile"
webpcdir="/usr/local/nginx/html/pc"
#webpcdir="/home/upfile/webpcdirdemo"
webmobiledir="/usr/local/nginx/html/mobile"
#webmobiledir="/home/upfile/webmobiledirdemo"

cd $ftppcdir
ls -1 > $scriptdir/temp.txt

if [ -s $scriptdir/temp.txt ]
then
    echo "pc directory not null">> $scriptdir/logs.log
    for i in `cat $scriptdir/temp.txt`
    do
        if [ -d $i ]
        then
            echo "up trans directory,now mv to $webpcdir" >> $scriptdir/logs.log
            cd $ftppcdir
            find | sed '1d' > $scriptdir/objtemp.txt
            for obj in `cat $scriptdir/objtemp.txt`
            do
                if [ -f $obj ]
                then
                    webdir=$(dirname $obj)
                    webdir=${webdir#*./}
                    webfile=$(basename $obj)
                    if [ -d $webpcdir/$webdir ]
                    then
                        cd $webpcdir
                        tar cvfz $backupdir/webpcdir_bak_`date +%Y%m%d%H%M%S`.tar.gz ./$webdir >> $scriptdir/logs.log 2>&1
                        mv -f $ftppcdir/$webdir/$webfile $webpcdir/$webdir/$webfile
                    else
                        mkdir -p $webpcdir/$webdir
                        mv -f $ftppcdir/$webdir/$webfile $webpcdir/$webdir/$webfile
                    fi
                fi
            sleep 5
            done
        else
            webfile=${i##*.}
            if [[ "$webfile"x = "zip"x || "$webfile"x = "ZIP"x ]]
            then
                echo "up zip file,now backup webpcdir,and extract from zip file cover web site" >> $scriptdir/logs.log
                cd $webpcdir
                tar cvfz $backupdir/webpcdir_bak_`date +%Y%m%d%H%M%S`.tar.gz ./* >> $scriptdir/logs.log 2>&1
                rm -rf ./*
                cd $ftppcdir
                unzip -o -d  $webpcdir $ftppcdir/$i >> $scriptdir/logs.log 2>&1
            else
                cd $webpcdir
                tar cvfz $backupdir/webpcdir_bak_`date +%Y%m%d%H%M%S`.tar.gz $i >> $scriptdir/logs.log 2>&1
                cd $ftppcdir
                mv -f $i $webpcdir
            fi
        fi
    cd $ftppcdir
    rm -rf $i
    done
fi

cd $ftpmobiledir
ls -1 > $scriptdir/temp.txt

if [ -s $scriptdir/temp.txt ]
then
    echo "pc directory not null">> $scriptdir/logs.log
    for i in `cat $scriptdir/temp.txt`
    do
        if [ -d $i ]
        then
            echo "up trans directory,now mv to $webmobiledir" >> $scriptdir/logs.log
            cd $ftpmobiledir
            find | sed '1d' > $scriptdir/objtemp.txt
            for obj in `cat $scriptdir/objtemp.txt`
            do
                if [ -f $obj ]
                then
                    webdir=$(dirname $obj)
                    webdir=${webdir#*./}
                    webfile=$(basename $obj)
                    if [ -d $webmobiledir/$webdir ]
                    then
                        cd $webmobiledir
                        tar cvfz $backupdir/webmobiledir_bak_`date +%Y%m%d%H%M%S`.tar.gz ./$webdir >> $scriptdir/logs.log 2>&1
                        mv -f $ftpmobiledir/$webdir/$webfile $webmobiledir/$webdir/$webfile
                    else
                        mkdir -p $webmobiledir/$webdir
                        mv -f $ftpmobiledir/$webdir/$webfile $webmobiledir/$webdir/$webfile
                    fi
                fi
            sleep 5
            done
        else
            webfile=${i##*.}
            if [[ "$webfile"x = "zip"x || "$webfile"x = "ZIP"x ]]
            then
                echo "up zip file,now backup webmobiledir,and extract from zip file cover web site" >> $scriptdir/logs.log
                cd $webmobiledir
                tar cvfz $backupdir/webmobiledir_bak_`date +%Y%m%d%H%M%S`.tar.gz ./* >> $scriptdir/logs.log 2>&1
                rm -rf ./*
                cd $ftpmobiledir
                unzip -o -d  $webmobiledir $ftpmobiledir/$i >> $scriptdir/logs.log 2>&1
            else
                cd $webmobiledir
                tar cvfz $backupdir/webmobiledir_bak_`date +%Y%m%d%H%M%S`.tar.gz $i >> $scriptdir/logs.log 2>&1
                cd $ftpmobiledir
                mv -f $i $webmobiledir
            fi
        fi
    cd $ftpmobiledir
    rm -rf $i
    done
fi

echo "delete temp file" >> $scriptdir/logs.log
cd $scriptdir
rm -rf temp.txt
rm -rf objtemp.txt
echo "--------------------------------`date +%Y%m%d%H%M%S`--------------------------------" >> $scriptdir/logs.log
