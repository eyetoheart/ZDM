#!/bin/bash

echo "`date +"%Y-%m-%d_%H:%M:%S"`" >> /dzl/muck/app/source/log.txt
echo "============start to git pull=============="

cd /dzl/muck/app/source/muckplatform

git pull

echo "============ git pull end =============="

service_url_arr=("/gateway/" "/eureka_server/" "/data-information-service/" "/muckplatform-service/" "/data-visualization-service/" "/redis-service/" "/gps-data-reception/" "/bayonet-service/" "/uploadfile-service/" "/mail-service/" "/monitorcore-service/" "/muck-analysis/" "/sign-bill-service/" "/transaction-service/" "/education-service/" "/videoanalysis-service/" "/transferprocess-service/" "/muckplatform-app/" "/weigh-service" "/gps-data-processing/")

#菜单部署——渣土 test
function menu()
{
echo -e `date`
cat <<EOF
-----------------------------------
>>>请选择要构建的模块:
`echo -e "\033[35m 1）gateway\033[0m"`
`echo -e "\033[35m 2）eureka\033[0m"`
`echo -e "\033[35m 3）data-information-service\033[0m"`
`echo -e "\033[35m 4）muckplatform-service\033[0m"`
`echo -e "\033[35m 5）data-visualization-service\033[0m"`
`echo -e "\033[35m 6）redis-service\033[0m"`
`echo -e "\033[35m 7）gps-data-reception\033[0m"`
`echo -e "\033[35m 8）bayonet-service\033[0m"`
`echo -e "\033[35m 9）uploadfile-service\033[0m"`
`echo -e "\033[35m 10) mail-service\033[0m"`
`echo -e "\033[35m 11) monitorcore-service\033[0m"`
`echo -e "\033[35m 12) muck-analysis\033[0m"`
`echo -e "\033[35m 13) sign-bill-service\033[0m"`
`echo -e "\033[35m 14) transaction-service\033[0m"`
`echo -e "\033[35m 15) education-service\033[0m"`
`echo -e "\033[35m 16) videoanalysis-service\033[0m"`
`echo -e "\033[35m 17) transferprocess-service\033[0m"`
`echo -e "\033[35m 18) muckplatform-app\033[0m"`
`echo -e "\033[35m 19) weigh-service\033[0m"`
`echo -e "\033[35m 20) gps-data-processing\033[0m"`
`echo -e "\033[35m A）All\033[0m"`
`echo -e "\033[35m Q)退出\033[0m"`
EOF
read -p "请输入对应序列号：" num1
case $num1 in
    1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20)
	echo -e "\033[35m 切换至对应模块：/dzl/muck/app/source/muckplatform${service_url_arr[num1-1]} 目录开始构建…… \033[0m"
    cd /dzl/muck/app/source/muckplatform${service_url_arr[num1-1]}
    mvn clean package install
    echo -e "\033[35m 构建${service_url_arr[num1-1]} 模块完成\033[0m"
    menu
    ;;
    A|a)
    echo -e "\033[32m--------全部--------- \033[0m"
   	cd /dzl/muck/app/source/muckplatform
   	mvn clean package install
   	echo -e "\033[35m 构建全部模块完成\033[0m"
   	menu
    ;;
    Q|q)
    echo -e "\033[32m--------退出--------- \033[0m"
    exit 0
    ;;
    *)
    echo -e "\033[31m err：请输入正确的编号:\033[0m"
    menu
esac
}
menu
