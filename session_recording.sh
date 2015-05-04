# Terminal Session Recording
#
# Uses script to record all terminal sessions to for later review.
#
# usage: source in .bashrc and all terminal sessions will be saved in
# ~/terminal-logs
# Warning: sometimes this breaks nx clients for an unknown reason.

if [ -z "$UNDER_SCRIPT" ]; then
  logdir=$HOME/terminal-logs
  if [ ! -d $logdir ]; then
    mkdir $logdir
  else
    gzip -q $logdir/*.log
  fi
  logfile=$logdir/$(date +%F_%T).$$.log
  export UNDER_SCRIPT=$logfile
  script -f -q $logfile
  exit
fi
