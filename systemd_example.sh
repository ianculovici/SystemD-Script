#!/bin/sh

# This service only runs as root
[ "$(id -u)" = 0 ] && {
    PreCmd="runuser ${USER} -c"
} || {
      echo $0 must run as root.
    exit 1
}

# CMD is the actual command that runs the service (e.g. httpd)

SERVICE_DIR=/opt/sample_script
CMD="$SERVICE_DIR/sample_service"
SERVICE_NAME=SampleService
PID_FILE_DIR=/var/run/sample_service
PID_FILE=${PID_FILE_DIR}/sample.pid
LOGFILE=/var/logs/sample_service.log
LOGFILEDATE=`date '+%F:%T'`
USER=sample_user
USAGE_TEXT="Usage: $0 start|stop|restart|status"

start_service () {
      if [ ! -f $PID_FILE ]; then
            echo -n "Starting $SERVICE_NAME... "
            PID=`${PreCmd} "nohup $CMD >> ${LOGFILE} 2>&1 </dev/null & echo \\\$! "`
            echo $PID > $PID_FILE
            chown $USER:$USER $PID_FILE
            echo "Started!"
            ${PreCmd} "echo $0: $SERVICE_NAME startup $LOGFILEDATE" >> "${LOGFILE}"
      else
            echo "$SERVICE_NAME is already running. PID file exists."
      fi
}

stop_service () {
    status_service do_stop
}

status_service () {
    SERVICE_STATUS=""
      if [ -f $PID_FILE ]; then
            PID=$(cat $PID_FILE);
            if [ "$PID" = "" ]; then
                  echo "$SERVICE_NAME is in an unknown state. Please restart. "
            else
                  is_running=`ps -e | grep $PID | wc -l`
                  if [ "$is_running" = "1" ]; then
                        if [ "$1" = "" ]; then
                        # this is just status
                              echo "$SERVICE_NAME is running"
                        else
                              if [ "$1" = "do_stop" ]; then
                                    echo -n "$SERVICE_NAME stopping... "
                                    kill "$PID"
                                    echo "Stopped!"
                                    rm $PID_FILE
                                    ${PreCmd} "echo $0: [$LOGFILEDATE] $SERVICE_NAME shutdown" >> "${LOGFILE}"
                              fi
                        fi
                  else
                        rm $PID_FILE
                        echo "$SERVICE_NAME is not running. PID file cleaned up."
                  fi
            fi
      else
            echo "$SERVICE_NAME is not running."
      fi
}

[ "$1" = "" ] && {
    echo $USAGE_TEXT
    echo ""
    exit 1
}

[ -d ${PID_FILE_DIR} ] || {
        mkdir -p $PID_FILE_DIR
        chown $USER:$USER $PID_FILE_DIR
}

case $1 in
    start)
        cd ${SERVICE_DIR}
        start_service && sleep 1
    ;;
    stop)
        stop_service
    ;;
    restart)
        stop_service
        sleep 2
        start_service && sleep 1
    ;;
    status)
        status_service
esac
