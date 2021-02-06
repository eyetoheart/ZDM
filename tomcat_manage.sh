#!/bin/sh

PROGNAME=$(basename "$0")
PROGPATH=$(echo "$0" | sed -e 's,[\\/][^\\/][^\\/]*$,,')
PROGCONF=$PROGPATH/config.txt

print_usage() {

    echo -e "没有检测到脚本文件同目录下的配置文件，请先编辑一个名为：config.txt 的配置文件，该配置文件说明: \n\
配置文件以冒号分割为三列，第一列表示容器的名字，第二列表示容器内tomcat应用的路径,第三列表示应用的名称; \n\
如果应用部署在宿主机，则删除第一个冒号前面的部分即可，（冒号不可省略），例如: \n\

# 这是备注或说明行 \n\
container_name:/app/path:appname \n\
:/app/path:appname \n\

第一行：可在配置文件开头、结尾、中间中添加以#号开头的备注或说明行，但不可在配置项同一行后面添加#号及说明 \n\
第二行：容器名为container_name，容器内应用的路径为/app/path，应用的名称为appname(该列可任意命名,但不能有重复的名称) \n\
第三行：该行表示部署在宿主机/app/path的名为appname的tomcat应用，无容器环境\n"

}

nocontainer_restart () {

ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
if [ $? -eq 0 ]
then
    cd $APPPATH/bin
    ./shutdown.sh > /dev/null 2>&1
    sleep 5
    ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        uidnum="`ps -ef | grep java | grep $APPNAME | awk '{print $2}'`"
        kill -9 $uidnum
        sleep 5
        if [ -d $APPPATH/work ] ; then cd $APPPATH/work; rm -rf ./*; fi
        if [ -d $APPPATH/temp ] ; then cd $APPPATH/temp; rm -rf ./*; fi
        cd $APPPATH/bin
        ./startup.sh > /dev/null 2>&1
        sleep 3
        tail -f $APPPATH/logs/catalina.out
    else
        if [ -d $APPPATH/work ] ; then cd $APPPATH/work; rm -rf ./*; fi
        if [ -d $APPPATH/temp ] ; then cd $APPPATH/temp; rm -rf ./*; fi
        cd $APPPATH/bin
        ./startup.sh > /dev/null 2>&1
        sleep 3
        tail -f $APPPATH/logs/catalina.out
    fi
else
    if [ -d $APPPATH/work ] ; then cd $APPPATH/work; rm -rf ./*; fi
    if [ -d $APPPATH/temp ] ; then cd $APPPATH/temp; rm -rf ./*; fi
    cd $APPPATH/bin
    ./startup.sh > /dev/null 2>&1
    sleep 3
    tail -f $APPPATH/logs/catalina.out
fi

}

container_restart () {

docker exec $CONTAINERNAME ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
if [ $? -eq 0 ]
then
    docker exec $CONTAINERNAME $APPPATH/bin/shutdown.sh > /dev/null 2>&1
    sleep 5
    docker exec $CONTAINERNAME ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        uidnum="`docker exec $CONTAINERNAME ps -ef | grep java | grep $APPNAME | awk '{print $2}'`"
        docker exec $CONTAINERNAME kill -9 $uidnum
        sleep 5
        docker exec $CONTAINERNAME bash -c "cd $APPPATH/work && rm -rf $APPPATH/work/*"
        docker exec $CONTAINERNAME bash -c "cd $APPPATH/temp && rm -rf $APPPATH/temp/*"
        docker exec -e LANG=en_US.UTF-8 $CONTAINERNAME $APPPATH/bin/startup.sh > /dev/null 2>&1
        sleep 3
        docker exec $CONTAINERNAME tail -f $APPPATH/logs/catalina.out
    else
        docker exec $CONTAINERNAME bash -c "cd $APPPATH/work && rm -rf $APPPATH/work/*"
        docker exec $CONTAINERNAME bash -c "cd $APPPATH/temp && rm -rf $APPPATH/temp/*"
        docker exec -e LANG=en_US.UTF-8 $CONTAINERNAME $APPPATH/bin/startup.sh > /dev/null 2>&1
        sleep 3
        docker exec $CONTAINERNAME tail -f $APPPATH/logs/catalina.out    
    fi
else
    docker exec $CONTAINERNAME bash -c "cd $APPPATH/work && rm -rf $APPPATH/work/*"
    docker exec $CONTAINERNAME bash -c "cd $APPPATH/temp && rm -rf $APPPATH/temp/*"
    docker exec -e LANG=en_US.UTF-8 $CONTAINERNAME $APPPATH/bin/startup.sh > /dev/null 2>&1
    sleep 3
    docker exec $CONTAINERNAME tail -f $APPPATH/logs/catalina.out
fi

}

nocontainer_stop () {

ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
if [ $? -eq 0 ]
then
    cd $APPPATH/bin
    ./shutdown.sh > /dev/null 2>&1
    sleep 5
    ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        uidnum="`ps -ef | grep java | grep $APPNAME | awk '{print $2}'`"
        kill -9 $uidnum
        echo "应用 $ALIASAPPNAME 已停止"
    fi
else
    echo "应用 $ALIASAPPNAME 没有启动"
fi

}

container_stop () {

docker exec $CONTAINERNAME ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
if [ $? -eq 0 ]
then
    docker exec $CONTAINERNAME $APPPATH/bin/shutdown.sh > /dev/null 2>&1
    sleep 5
    docker exec $CONTAINERNAME ps -ef | grep java | grep $APPNAME > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        uidnum="`docker exec $CONTAINERNAME ps -ef | grep java | grep $APPNAME | awk '{print $2}'`"
        docker exec $CONTAINERNAME kill -9 $uidnum
    fi
    echo "容器 $CONTAINERNAME 中的应用 $ALIASAPPNAME 已停止"
else
    echo "容器 $CONTAINERNAME 中的应用 $ALIASAPPNAME 没有启动"
fi

}

nocontainer_taillog () {

cd $APPPATH/logs
if [ -f $APPPATH/logs/catalina.out ]
then
    tail -100f $APPPATH/logs/catalina.out
else
    echo "$APPPATH/logs/catalina.out 文件不存在"
fi

}

container_taillog () {

docker exec $CONTAINERNAME bash -c "tail -100f $APPPATH/logs/catalina.out"

}

if [ ! -s $PROGCONF ]
then
    print_usage
    exit 1
fi

echo "以下是部署在本服务器上的tomcat应用列表:"
echo
configfilelinenumber="`sed '/^$/d;/^#/d' $PROGCONF | wc -l | awk '{print $1}'`"
sed '/^$/d;/^#/d' $PROGCONF | awk -F: '{print NR,":",$3}'
echo 

echo -e "请选择你想操作的应用前面的数字:\c"
read appnum
/usr/bin/seq 1 $configfilelinenumber | grep $appnum > /dev/null 2>&1
if [ $? -eq 0 ]
then
    ALIASAPPNAME="`sed '/^$/d;/^#/d' $PROGCONF | awk -F: '{print NR,":",$3}' | awk -F ': ' 'NR == '$appnum' {print $2}'`"
    APPPATH="`sed '/^$/d;/^#/d' $PROGCONF | awk -F: '$3 ~ /'$ALIASAPPNAME'/ {print $2}'`"
    APPNAME="`echo $APPPATH | xargs basename`"
    CONTAINERNAME="`sed '/^$/d;/^#/d' $PROGCONF | awk -F: '$3 ~ /'$ALIASAPPNAME'/ {print $1}'`"
    echo
    echo -e "1. 重启该应用;\n\
2. 停止该应用;\n\
3. 查看该应用的日志"
    echo
    echo -e "你选择需要操作的应用是:`sed '/^$/d;/^#/d' $PROGCONF | awk -F: '{print NR,":",$3}' | awk -F ': ' 'NR == '$appnum' {print $2}'`,请继续选择你的动作:\c" 
    read actionnum
    case $actionnum in
    1)
        echo -e "你希望重启的应用是: `sed '/^$/d;/^#/d' $PROGCONF | awk -F: '{print NR,":",$3}' | awk -F ': ' 'NR == '$appnum' {print $2}'`,你确信要重启这个应用吗([Y/y] ro [N/n]):\c"
        read YORN
        if [ x"$YORN" = x"Y" -o x"$YORN" = x"y" ]
        then
            if [ -z "$CONTAINERNAME" ]
            then
               echo "开始重启宿主机上的 $ALIASAPPNAME 应用 ..."
               nocontainer_restart
            else
               echo "开始重启容器 $CONTAINERNAME 内的 $ALIASAPPNAME 应用 ..."
               container_restart
            fi
        elif [ x"$YORN" = x"N" -o x"$YORN" = x"n" ]
        then
            echo "你选择了不重启应用，现在将退出本程序"
            exit 0
        else
            echo "你输入的字符不正确，请输入[Y|y]或者[N|n]，请重新运行该脚本程序，重新选择"
            exit 1
        fi
    ;;

    2)
    echo -e "你希望停止的应用是: `sed '/^$/d;/^#/d' $PROGCONF | awk -F: '{print NR,":",$3}' | awk -F ': ' 'NR == '$appnum' {print $2}'`,你确信要停止这个应用吗([Y/y] ro [N/n]):\c"
    read YORN
    if [ x"$YORN" = x"Y" -o x"$YORN" = x"y" ]
    then
        if [ -z "$CONTAINERNAME" ]
        then
            echo "开始停止宿主机上的 $ALIASAPPNAME 应用 ..."
            nocontainer_stop
        else
            echo "开始停止容器 $CONTAINERNAME 内的 $ALIASAPPNAME 应用 ..."
            container_stop
        fi
    elif [ x"$YORN" = x"N" -o x"$YORN" = x"n" ]
    then
        echo "你选择了不停止应用，现在将退出本程序"
        exit 0
    else
        echo "你输入的字符不正确，请输入[Y|y]或者[N|n]，请重新运行该脚本程序，重新选择"
        exit 1
    fi
    ;;

    3)
    if [ -z "$CONTAINERNAME" ]
    then
        echo "开始tail宿主机上的 $ALIASAPPNAME 的catalina.out日志,按Ctrl + c退出 ..."
        sleep 3
        nocontainer_taillog
    else
        echo "开始tail容器 $CONTAINERNAME 内的 $ALIASAPPNAME 的catalina.out日志,按Ctrl + c退出 ..."
        sleep 3
        container_taillog
    fi
    ;;

    *)
    echo "你选择的动作不正确，请重新选择"
    ;;
    esac

else
    echo "你输入的数字不正确，请重新运行该脚本程序，重新选择"
    exit 1
fi
