#!/bin/sh
for i in `cat  passwd`
do
    echo $i | awk -F: '!/^#/ && $1 !~ /callcenter|callcenter/ {printf("%s"",",$1);}'
done
echo

上面脚本执行输出的结果：
jenkins,callcenter,tiandaxin,zhangdaoming,chenwanjun,wenbingcai,yangfan,zhaozhiheng,liyan,liuzhao,bishoubo,pengtao,.....等等吧，我就不写了，就是passwd文件不是以#号开头的账号名的排列




passwd文件的内容：
jenkins:jksfkjashfjaswheoiqhdva
callcenter:jksfkjashfjaswheoiqhdva
tiandaxin:jksfkjashfjaswheoiqhdva
zhangdaoming:jksfkjashfjaswheoiqhdva
chenwanjun:jksfkjashfjaswheoiqhdva
wenbingcai:jksfkjashfjaswheoiqhdva
pengtao:jksfkjashfjaswheoiqhdva
bishoubo:jksfkjashfjaswheoiqhdva
liuzhao:jksfkjashfjaswheoiqhdva
liyan:jksfkjashfjaswheoiqhdva
zhaozhiheng:jksfkjashfjaswheoiqhdva
yangfan:jksfkjashfjaswheoiqhdva
zhouyang:jksfkjashfjaswheoiqhdva
jifaxia:jksfkjashfjaswheoiqhdva
liuying:jksfkjashfjaswheoiqhdva
mengzhenghong:jksfkjashfjaswheoiqhdva
zhangxu:jksfkjashfjaswheoiqhdva
lichengshuai:jksfkjashfjaswheoiqhdva
liuhongtao:jksfkjashfjaswheoiqhdva
zhangjiying:jksfkjashfjaswheoiqhdva
yangchuang:jksfkjashfjaswheoiqhdva
wangcheng:jksfkjashfjaswheoiqhdva
shaolongsheng:jksfkjashfjaswheoiqhdva
guoyaqing:jksfkjashfjaswheoiqhdva
test:jksfkjashfjaswheoiqhdva
weipei:jksfkjashfjaswheoiqhdva

#jiapei:jksfkjashfjaswheoiqhdva
#zhaojunchao:jksfkjashfjaswheoiqhdva
#jiwei:jksfkjashfjaswheoiqhdva
#zhaijingping:jksfkjashfjaswheoiqhdva
#taijinqiao:jksfkjashfjaswheoiqhdva
#yanfei:jksfkjashfjaswheoiqhdva
#liuting:jksfkjashfjaswheoiqhdva
#zhangtongling:jksfkjashfjaswheoiqhdva
#hengjihong:jksfkjashfjaswheoiqhdva
#zhaoming:jksfkjashfjaswheoiqhdva
#wushufeng:jksfkjashfjaswheoiqhdva
#wanglibo:jksfkjashfjaswheoiqhdva
#weizhen:jksfkjashfjaswheoiqhdva
#libo:jksfkjashfjaswheoiqhdva
#zhangtao:jksfkjashfjaswheoiqhdva
#xingyuhuan:jksfkjashfjaswheoiqhdva
#changweipeng:jksfkjashfjaswheoiqhdva
#zhangchong:jksfkjashfjaswheoiqhdva
#dufeng:jksfkjashfjaswheoiqhdva
#liutao:jksfkjashfjaswheoiqhdva
#liuqifang:jksfkjashfjaswheoiqhdva
#liyanlei:jksfkjashfjaswheoiqhdva
#fengsuhang:jksfkjashfjaswheoiqhdva
#gaoruihua:jksfkjashfjaswheoiqhdva
#chenshaohua:jksfkjashfjaswheoiqhdva
#furong:jksfkjashfjaswheoiqhdva
#kongdefang:jksfkjashfjaswheoiqhdva
#lifengxia:jksfkjashfjaswheoiqhdva
#tiandaxin:jksfkjashfjaswheoiqhdva
#huanghonggang:jksfkjashfjaswheoiqhdva
#wangyu:jksfkjashfjaswheoiqhdva
#tangweifeng:jksfkjashfjaswheoiqhdva
#lipo:jksfkjashfjaswheoiqhdva
#kongxiangshui:jksfkjashfjaswheoiqhdva
#cuiqingchao:jksfkjashfjaswheoiqhdva
#dingliansong:jksfkjashfjaswheoiqhdva
#wuguanyong:jksfkjashfjaswheoiqhdva
#mayuliang:jksfkjashfjaswheoiqhdva
#chuchunfei:jksfkjashfjaswheoiqhdva
#lifengxia:jksfkjashfjaswheoiqhdva
#zhangjiayang:jksfkjashfjaswheoiqhdva
#liuzhao:jksfkjashfjaswheoiqhdva
#mazongwang:jksfkjashfjaswheoiqhdva
#shaohang:jksfkjashfjaswheoiqhdva
#zhouyang:jksfkjashfjaswheoiqhdva
#sunjihua:jksfkjashfjaswheoiqhdva
#yubineng:jksfkjashfjaswheoiqhdva
#lvpeidong:jksfkjashfjaswheoiqhdva
#liurenpeng:jksfkjashfjaswheoiqhdva
#shibeilei:jksfkjashfjaswheoiqhdva
#helu:jksfkjashfjaswheoiqhdva
#zhangdinghao:jksfkjashfjaswheoiqhdva
#zhengwanjun:jksfkjashfjaswheoiqhdva
#dongshiqi:jksfkjashfjaswheoiqhdva
#penghuaxia:jksfkjashfjaswheoiqhdva
#zhangziyan:jksfkjashfjaswheoiqhdva
#lixiongfei:jksfkjashfjaswheoiqhdva
#yanchaochao:jksfkjashfjaswheoiqhdva
#liudongjian:jksfkjashfjaswheoiqhdva
#haoboyu:jksfkjashfjaswheoiqhdva
#houjianwei:jksfkjashfjaswheoiqhdva
#jinlong:jksfkjashfjaswheoiqhdva
#qideyu:jksfkjashfjaswheoiqhdva
#wangjinxu:jksfkjashfjaswheoiqhdva
#lihaibo:jksfkjashfjaswheoiqhdva
#wangyansong:jksfkjashfjaswheoiqhdva
#chenhuiyan:jksfkjashfjaswheoiqhdva
#wangyanlin:jksfkjashfjaswheoiqhdva
#yangyibo:jksfkjashfjaswheoiqhdva
#zhulianqiu:jksfkjashfjaswheoiqhdva
#zhangze:jksfkjashfjaswheoiqhdva
#chengpeng:jksfkjashfjaswheoiqhdva
#xiaobo:jksfkjashfjaswheoiqhdva
#suxiaoyan:jksfkjashfjaswheoiqhdva
#wuguoliang:jksfkjashfjaswheoiqhdva
#zhangyang:jksfkjashfjaswheoiqhdva
#wangyingwei:jksfkjashfjaswheoiqhdva
#zhouyulong:jksfkjashfjaswheoiqhdva
#zhongsheng:jksfkjashfjaswheoiqhdva
#mengxuan:jksfkjashfjaswheoiqhdva
#huangyanxia:jksfkjashfjaswheoiqhdva
#haoboyu:jksfkjashfjaswheoiqhdva
#zhangwenbin:jksfkjashfjaswheoiqhdva
#fangchao:jksfkjashfjaswheoiqhdva
#zhanghuanling:jksfkjashfjaswheoiqhdva
#zhaoyanjun:jksfkjashfjaswheoiqhdva
#zhangbo:jksfkjashfjaswheoiqhdva
#zhangxw:jksfkjashfjaswheoiqhdva
#liuke:jksfkjashfjaswheoiqhdva
#mazhaoyang:jksfkjashfjaswheoiqhdva
#liujingchao:jksfkjashfjaswheoiqhdva
#jiapei:jksfkjashfjaswheoiqhdva
#jiapei:jksfkjashfjaswheoiqhdva
