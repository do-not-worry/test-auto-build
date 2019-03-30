#!/bin/sh
#Jenkins自动登录构建脚本
#$1:延迟构建时间 如1则延迟1秒



CONFIG_FILE=./build.conf
COOKIE_FILE=./cookie.txt
LOG_FILE=./run.log
userAgent='Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
retryNum=0

#构建
function build()
{
	buildUrl=`cat ${CONFIG_FILE} | grep 'buildUrl' | awk -F'buildUrl=' '{print($2)}'`
	customHeader=`cat ${CONFIG_FILE} | grep 'customHeader' | awk -F'customHeader=' '{print($2)}'`
	
	httpCode=`curl -d "delay=0sec" -H "${customHeader}" -A "${userAgent}" -b "${COOKIE_FILE}" -w %{http_code} "${buildUrl}"`
	if [ ${httpCode} == "201" ];then
		log "构建成功！"
	elif [[ ${httpCode} =~ "403" ]];then
		log "登录信息已过期,重新登录中..."
		doLogin
		
		#循环登录3次退出
		if [ ${retryNum} -eq 3 ];then
			log "重复登录3次,自动退出"
			exit
		fi
		
		build
	else
		log "构建请求异常"
	fi
}

#打印日志,服务器时间不一致
function log()
{
	echo [`date -d"+8 hours" +"%Y-%m-%d %H:%M:%S"`] "$1" >> ${LOG_FILE}
}

#登录
function doLogin()
{
	let retryNum=retryNum+1
	loginUrl=`cat ${CONFIG_FILE} | grep 'loginUrl' | awk -F'loginUrl=' '{print($2)}'`
	username=`cat ${CONFIG_FILE} | grep 'username' | awk -F'username=' '{print($2)}'`
	password=`cat ${CONFIG_FILE} | grep 'password' | awk -F'password=' '{print($2)}'`
	postData="j_username=${username}&j_password=${password}&from=/&Submit=登录"
	
	curl -d ${postData} -A "${userAgent}" -c "${COOKIE_FILE}" "${loginUrl}"
}

if [ $1 -gt 0 ];then
	sleep $1
fi

build
