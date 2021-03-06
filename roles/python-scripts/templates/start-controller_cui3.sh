#!/bin/sh

DATE=$(date +"%Y%m%d")
OPTIME=$(date +"%Y%m%d-%H%M%S")
#結果の出力先ディレクトリを指定
LOGDIR=/var/www/html/${DATE}
#JMXファイルを指定
FILE_JMX=/usr/local/jmeter/bin/templates/build-web-test-plan.jmx
#ホストのIPアドレスを定義
SELF_IPADDR=192.168.33.10

# スレッド数
THREAD_NUM=`grep "ThreadGroup.num_threads" ${FILE_JMX} | sed -e "s/^.*<stringProp.*>\(.*\)<\/stringProp>.*$/\1/"`
# ランプアップ数
RAMPUP_NUM=`grep "ThreadGroup.ramp_time" ${FILE_JMX} | sed -e "s/^.*<stringProp.*>\(.*\)<\/stringProp>.*$/\1/"`
# ループ回数
LOOP_NUM=`grep "LoopController.loops" ${FILE_JMX} | sed -e "s/^.*<stringProp.*>\(.*\)<\/stringProp>.*$/\1/"`

# 日付ディレクトリの作成
mkdir -p ${LOGDIR}

# jmeterの実行
/usr/local/jmeter/bin/jmeter -Dsun.net.inetaddr.ttl=0 -n -t ${FILE_JMX} -j ${LOGDIR}/${OPTIME}.log -l ${LOGDIR}/${OPTIME}.jtl -e -o ${LOGDIR}/${OPTIME}_th${JMETER_THREAD}${2}/ -r

# CSVファイルの作成
cat ${LOGDIR}/${OPTIME}_th${JMETER_THREAD}${2}/statistics.json | jq  -r ". [] | [.transaction,.sampleCount,.errorCount,.errorPct,.meanResTime,.minResTime,.maxResTime,.pct1ResTime,.pct2ResTime,.pct3ResTime,.throughput,.receivedKBytesPerSec,.sentKBytesPerSec] | @csv" | grep "Total" > ${LOGDIR}/${OPTIME}_th${JMETER_THREAD}${2}/statistics.csv

# スプレッドシートに結果を出力
/usr/local/bin/main3.py ${LOGDIR}/${OPTIME}_th/statistics.csv http://${SELF_IPADDR}/${DATE}/${OPTIME}_th ${OPTIME} ${THREAD_NUM} ${RAMPUP_NUM} ${LOOP_NUM}
