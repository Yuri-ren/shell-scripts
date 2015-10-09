#!/bin/bash

CURRENT_DATE=$(date +%Y-%m-%d)
TOMCAT_LOG_FILE=/usr/local/tomcat1/logs
TOMCAT2_LOG_FILE=/usr/local/tomcat2/logs
CURRENT_YEAR=$(date +%Y)

###创建日志暂存目录
mkdir /root/temp-log -p

####find the log file
read -p "需要取哪一天的tomcat日志？取当天的日志直接Enter键,其他日期格式如XX-XX(Month-Day):" LOG_DATE
if [ "$LOG_DATE" == '' ];then
        LOGFILE1=$TOMCAT_LOG_FILE/catalina.out
        LOGFILE2=$TOMCAT2_LOG_FILE/catalina.out
	echo $CURRENT_DATE
	input_str=$(echo $CURRENT_DATE|cut -d'-' -f3)
	if [ "$input_str" -ge 10 ];then
		LOG_TIME=$(date +%b' '%_d)
	else
		LOG_TIME=$(date +%b%_d)
	fi
else
        month=`echo $LOG_DATE|cut -d '-' -f 1`
	####tomcat1
	if [ -e "$TOMCAT_LOG_FILE/$month/catalina.out.$CURRENT_YEAR-$LOG_DATE" ];then
		echo "tomcat1日志文件存在~~~"
        	LOGFILE1=$TOMCAT_LOG_FILE/$month/catalina.out.$CURRENT_YEAR'-'$LOG_DATE
	else
		echo "解压tomcat1日志压缩文件~~"
		/bin/tar -xzf "$TOMCAT_LOG_FILE/$month/$(date +%Y)-$LOG_DATE.tgz" -C "$TOMCAT_LOG_FILE/$month/"
        	LOGFILE1=$TOMCAT_LOG_FILE/$month/catalina.out.$CURRENT_YEAR'-'$LOG_DATE
	fi
	####tomcat2
	if [ -e "$TOMCAT2_LOG_FILE/$month/catalina.out.$CURRENT_YEAR-$LOG_DATE" ];then
		echo "tomcat2日志文件存在~~~"
        	LOGFILE2=$TOMCAT2_LOG_FILE/$month/catalina.out.$CURRENT_YEAR'-'$LOG_DATE
	else
		echo "解压tomcat2日志压缩文件~~"
		/bin/tar -xzf "$TOMCAT2_LOG_FILE/$month/$(date +%Y)-$LOG_DATE.tgz" -C "$TOMCAT2_LOG_FILE/$month/"
        	LOGFILE2=$TOMCAT2_LOG_FILE/$month/catalina.out.$CURRENT_YEAR'-'$LOG_DATE
	fi
#######根据日志确定sed传入的时间参数
	input_str=$(echo $LOG_DATE|cut -d'-' -f2)
	if [ "$input_str" -ge 10 ];then
		LOG_TIME=$(date -d "$CURRENT_YEAR-$LOG_DATE" +%b' '%_d)
	else
		LOG_TIME=$(date -d "$CURRENT_YEAR-$LOG_DATE" +%b%_d)
	fi
fi
echo $LOGFILE1
echo $LOGFILE2
echo $LOG_TIME

echo "在下面输入起始时间,使用正则表达式格式，例如10:00.*AM"
read -p "开始时间:ex 5:00:.*PM" START_TIME 
read -p "结束时间:ex 6:00:.*PM" END_TIME 
begin="$LOG_TIME, $CURRENT_YEAR $START_TIME"
end="$LOG_TIME, $CURRENT_YEAR $END_TIME"
`sed -n "/$begin/,/$end/"p "$LOGFILE1" >/root/temp-log/tomcat1.log`
`sed -n "/$begin/,/$end/"p "$LOGFILE2" >/root/temp-log/tomcat2.log`

/usr/bin/zip /root/temp-log/$CURRENT_DATE.zip /root/temp-log/tomcat*.log

