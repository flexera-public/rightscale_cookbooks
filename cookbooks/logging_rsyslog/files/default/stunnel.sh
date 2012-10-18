#! /bin/sh -e
### BEGIN INIT INFO
# chkconfig: 2345 10 90
# description: Activates/Deactivates stunnel
# Provides:          stunnel
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Should-Start:      $syslog
# Should-Stop:       $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start or stop stunnel 4.x (SSL tunnel for network daemons)
### END INIT INFO

DEFAULTPIDFILE="/var/run/stunnel/stunnel.pid"
DAEMON="/usr/bin/stunnel"
NAME=stunnel
DESC="SSL tunnels"
FILES="/etc/stunnel/stunnel.conf"
OPTIONS=""
ENABLED=0

get_pids() {
  local file=$1
  if test -f $file; then
    CHROOT=`grep "^chroot" $file|sed "s;.*= *;;"`
    PIDFILE=`grep "^pid" $file|sed "s;.*= *;;"`
    if [ "$PIDFILE" = "" ]; then
      PIDFILE=$DEFAULTPIDFILE
    fi
    if test -f $CHROOT/$PIDFILE; then
      cat $CHROOT/$PIDFILE
    fi
  fi
}

startdaemons() {
  if ! [ -d /var/run/stunnel ]; then
    rm -rf /var/run/stunnel
    install -d -o nobody -g nobody /var/run/stunnel
  fi
  for file in $FILES; do 
    if test -f $file; then
      ARGS="$file $OPTIONS"
      PROCLIST=`get_pids $file`
      if [ "$PROCLIST" ] && kill -s 0 $PROCLIST 2>/dev/null; then
        echo -n "[Already running: $file] "
      elif $DAEMON $ARGS; then
    echo -n "[Started: $file] "
      else
    echo "[Failed: $file]"
    echo "You should check that you have specified the pid= in you configuration file"
    exit 1
      fi
    fi
  done;
}

killdaemons() {
  SIGNAL=${1:-TERM}
  for file in $FILES; do
    PROCLIST=`get_pids $file`
    if [ "$PROCLIST" ] && kill -s 0 $PROCLIST 2>/dev/null; then
       kill -s $SIGNAL $PROCLIST
       echo -n "[Stopped: $file] "
    fi
  done
}

if [ "x$OPTIONS" != "x" ]; then
  OPTIONS="-- $OPTIONS"
fi

test -x $DAEMON || exit 0

set -e

case "$1" in
  start)
        echo -n "Starting $DESC: "
        startdaemons
        echo "$NAME."
        ;;
  stop)
        echo -n "Stopping $DESC: "
        killdaemons
        echo "$NAME."
        ;;
  reload)
        echo -n "Reloading configuration $DESC: "
        killdaemons HUP
        echo "$NAME."
        ;;  
  restart)
        echo -n "Restarting $DESC: "
        killdaemons
        sleep 5
        startdaemons
        echo "$NAME."
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|reload|restart}" >&2
        exit 1
        ;;
esac

exit 0
