#!/bin/sh
for i in `cat  passwd`
do
    echo $i | awk -F: '!/^#/ && $1 !~ /callcenter|callcenter/ {printf("%s"",",$1);}'
done
echo

上面脚本执行输出的结果：
jenkins,callcenter,iandaxin,zhangdaoming,henwanjun,enbingcai,angfan,haohiheng,liyan,iuhao,ishoubo,engao,.....等等吧，我就不写了，就是passwd文件不是以#号开头的账号名的排列
