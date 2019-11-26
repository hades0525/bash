#!/bin/bash

APP_PATH="/opt/workspace/cdcg_share"
PROJECTNAME="cdcg-share"
JARNAME=$PROJECTNAME"-""*""-SNAPSHOT.jar"


function get_app_pid() {
    pid=$(ps -ef | grep -w java | grep -n 'cdcg-share-.*\.jar'|awk '{print $2}')
    echo "${pid}"
}

function start() {
    pid=$(get_app_pid)

    if [[ -n "${pid}" ]] ; then
        echo "${PROJECTNAME} is running, pid: ${pid}"
        return 0
    fi

    nohup java -Dloader.home=${APP_PATH} -Dloader.path=custom_config -jar ${APP_PATH}/$JARNAME >> ${APP_PATH}/logs/catalina.out 2>&1 &

    pid=$(get_app_pid)

    echo "start ${PROJECTNAME} success, pid: ${pid}"
}

function stop() {
    pid=$(get_app_pid)

    if [[ -z "${pid}" ]] ; then
        echo "${PROJECTNAME} is not running, no need to stop."
    else
        echo "$PROJECTNAME is running, kill pid: ${pid}"
        kill -9 ${pid}
    fi
}

function restart() {
    echo "restart ${PROJECTNAME} ..."
    stop
    start
    echo "restart ${PROJECTNAME} success."
}

function status() {
    pid=$(get_app_pid)
    if [[ -n ${pid} ]]; then
        echo "${PROJECTNAME} is running, pid:${pid}"
    else
        echo "${PROJECTNAME} is stopped"
    fi
}

function usage() {
    echo "sh $0 start|stop|restart|status"
}

function main() {
    action=$1
    case $1 in

        start)
            start
        ;;

        stop)
            stop
        ;;

        restart)
            restart
        ;;

        status)
            status
        ;;

        *)
            usage
        ;;
    esac
}

[[ $# -eq 0 ]] && usage && exit 1
action=$1
main $@
[[ $? -eq 0 ]] && echo "exec $action success." || echo "exec $action failed."

