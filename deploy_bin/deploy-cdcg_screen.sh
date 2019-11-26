#!/bin/bash

PROJECTNAME="cdcg-screen"
JARNAME=$PROJECTNAME"-""*""-SNAPSHOT.jar"

echo "start to run $JARNAME"

cd /opt/workspace/cdcg_screen

#jar running pid
pid=`ps -ef |grep $PROJECTNAME |grep -v "grep" |awk '{print $2}'`

if [ $pid ]; then
   echo "$PROJECTNAME  is  running  and to kill pid=$pid"
   kill -9 $pid
fi

echo "Start success to start $PROJECTNAME ...."
nohup java -Dloader.path=./custom_config -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005  -jar  $JARNAME  >> catalina.out  2>&1 &
