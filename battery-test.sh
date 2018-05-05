#!/bin/bash
#
# MacBook Pro Battery Life Test Script
# Author: Jeff Geerling, 2017
# changed to use simple "yes" stress test by Marsette Vona, 2018

# Detect if we're on AC or not
case "$OSTYPE" in
  # see: http://stackoverflow.com/a/21249561
  darwin*) [[ $(pmset -g ps | head -1) =~ "AC Power" ]] && AC=1 || AC=0 ;;
  # see: https://github.com/oxyc/dotfiles/blob/master/.local/bin/battery
  linux*) AC=$(cat /sys/class/power_supply/AC/online) ;;
  # fallback to running the script.
  *) AC=0 ;;
esac

# Make sure we're on battery
if [ $AC -eq 1 ]; then
  printf "\033[0;31mPlease unplug power before starting the test.\033[0m\n"; exit 1;
fi

# Friendly reminder
printf "Press [Ctrl+C] to stop the battery test...\n"

# Get the current time.
DATE="$(date +"%Y-%m-%d_%H.%M.%S")"

# Store results in a `results` directory
RESULTS_DIR="results"
RESULTS_FILE="$RESULTS_DIR/$DATE.csv"
mkdir -p $RESULTS_DIR
touch $RESULTS_FILE || exit 1

# Print Header Row in result file
printf "Counter,Time,Battery Percentage\n" >> $RESULTS_FILE

# Number of CPU cores
# works on OS X and Linux
# https://stackoverflow.com/a/23569003
NUM_CORES=`getconf _NPROCESSORS_ONLN`
echo "detected $NUM_CORES cpu cores"

# Time per loop iteration
SEC_PER_RUN=60
echo "running $NUM_CORES workers in $SEC_PER_RUN sec batches"

# Doing it this way vs killall suppresses bash job status messages
# https://stackoverflow.com/a/5722874
function kill_bg() {
  JOBS=$(jobs -rp)
  _JOBS=( $JOBS )
  echo "killing ${#_JOBS[@]} background processes..."
  kill $JOBS
  wait $JOBS 2>/dev/null
}

# Make sure the worker tasks get killed if user aborts test
trap ctrl_c INT
function ctrl_c() {
    kill_bg
    exit
}

# Counter for how many times the script has looped
TIMES_RUN=0

# Infinte Loop
while :
do
  # Write counter, time, and battery percentage to screen and file
  TIMESTAMP="$(date +"%Y-%m-%d %H:%M:%S")"
  case "$OSTYPE" in
    darwin*) BATTERY_PERCENT="$(pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto | cut -f1 -d'%')" ;;
    linux*) BATTERY_PERCENT="$(cat /sys/class/power_supply/BAT0/capacity)" ;;
    *) BATTERY_PERCENT="?" ;;
  esac
  echo "$TIMES_RUN,$TIMESTAMP,$BATTERY_PERCENT%" >> $RESULTS_FILE

  if [ "$TIMES_RUN" -eq 0 ]; then START_PERCENT=$BATTERY_PERCENT; fi

  echo "battery $BATTERY_PERCENT% at start of iteration $TIMES_RUN, $TIMESTAMP"
  if [ "$TIMES_RUN" -gt 0 ]; then
     PCT=$((START_PERCENT - BATTERY_PERCENT))
     SEC=$((TIMES_RUN * SEC_PER_RUN))
     # Use dc to get 3 decimal places of precision in the division
     RATE=`dc -e "3 k $PCT $SEC / p"`
     echo "drained ${PCT}% in ${SEC}s (${RATE}%/sec)"
     if [ "$RATE" != "0" ]; then
       TOGO=`dc -e "1 k $BATTERY_PERCENT $RATE / 60 / p"`
       echo "estimated ${TOGO}min left"
     fi
  fi
  echo "running $NUM_CORES parallel 'yes > /dev/null' for $SEC_PER_RUN sec..."

  for i in `seq 1 $NUM_CORES`; do
    yes > /dev/null &
  done

  sleep $SEC_PER_RUN

  kill_bg

  LAST_BATTERY_PERCENT=$BATTERY_PERCENT
  TIMES_RUN=$((TIMES_RUN + 1))
done
