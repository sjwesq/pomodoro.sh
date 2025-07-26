#!/bin/bash

################################################################################
# Function Definitions
################################################################################
clear_line () {
  printf "%80s\r" ""
}

timer_display () {
  local seconds=$1
  local label="$2"

  if [ "$label" != "" ]; then
    label="${label}:"
  fi

  while [ "$seconds" != 0 ]; do
    clear_line
    seconds_formatted="$(date -u -d "@$seconds" +%M:%S)"
    printf '%s %s\r' "$label" "$seconds_formatted"

    IFS= read -t 1 -n 1 pause # Doubles as a timer using `-t`
    if [ "$pause" != "" ]; then
      clear_line
      if [ "$minimal_mode" = true ]; then
        printf '%s %s [P]\r' "$label" "$seconds_formatted"
      else
        printf '%s %s | paused - press "s" to skip or any key to continue...\r' "$label" "$seconds_formatted"
      fi
      read -n 1 -s skip
      if [ "$skip" = 's' ]; then
        clear_line
        break
      fi
      # Prevents the timer from rapidly decrementing with many inputs
      seconds=$(($seconds + 1))
    fi
    seconds=$(($seconds - 1))
  done
}

number_check() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: '$1' is not a valid number." >&2
    exit 1
  fi
}
require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a valid file." >&2
    exit 1
  fi
}

################################################################################
# Script Execution
################################################################################

length_seconds_pomo=$((25*60))
length_seconds_shortbreak=$((5*60))
length_seconds_longbreak=$((20*60))

interval_longbreak=4
cycle_current=1
minimal_mode=false

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sound_notification="$DIR/sounds/notification.mp3"
sound_timeup="$DIR/sounds/timeup.mp3"

while getopts 'hmp:b:l:i:c:n:t:' OPTION; do
  case "$OPTION" in
    h)
      printf "Usage: %s [OPTION]...\n" "$0"
      printf "Displays a simple configurable pomodoro timer.\n"
      printf "Example: %s -p 20 -c 2 -n ~/Music/bell.mp3\n\n" "$0"

      printf "  -h\tDisplays this (h)elp screen\n\n"

      printf "  -m\tToggles (m)ini mode - designed for small terminals\n\n"

      printf "  -p\tLength of (p)omodoros in minutes (default %d)\n" \
        $((length_seconds_pomo/60))
      printf "  -b\tLength of (b)reaks in minutes (default %d)\n" \
        $((length_seconds_shortbreak/60))
      printf "  -l\tLength of (l)ong breaks in minutes (default %d)\n\n" \
        $((length_seconds_longbreak/60))

      printf "  -c\tCurrent pomodoro (c)ycle (default %d)\n" $cycle_current
      printf "  -i\t(i)nterval for how often long breaks are given (default %d)\n\n" \
        $interval_longbreak
      printf "  -n\tLocation of pomodoro-end (n)otification sound file\n"
      printf "  -t\tLocation of break (t)ime-up sound file\n"
      exit 0
      ;;
    m)
      minimal_mode=true
      ;;
    p)
      # Pomodoro length (minutes)
      number_check "$OPTARG"
      length_seconds_pomo=$((OPTARG * 60))
      ;;
    b)
      # Break length (minutes)
      number_check "$OPTARG"
      length_seconds_break=$((OPTARG * 60))
      ;;
    l)
      # Long break length (minutes)
      number_check "$OPTARG"
      length_seconds_longbreak=$((OPTARG * 60))
      ;;
    i)
      # Long break interval
      number_check "$OPTARG"
      interval_longbreak=$((OPTARG))
      ;;
    c)
      # Current cycle
      number_check "$OPTARG"
      cycle_current=$((OPTARG))
      ;;
    n)
      # Notification sound
      require_file "$OPTARG"
      sound_notification="$OPTARG"
      ;;
    t)
      require_file "$OPTARG"
      sound_timeup="$OPTARG"
      ;;
  esac
done


while :
do
  if [ "$minimal_mode" = true ]; then
    printf 'Pomodoro #%d?\r' $cycle_current
  else
    printf 'Press any key to start Pomodoro #%d...\r' $cycle_current
  fi
  read -n1 -s
  timer_display $length_seconds_pomo "Pomodoro #${cycle_current}"
  play "$sound_notification" &> /dev/null &

  if [ $((cycle_current % interval_longbreak)) = 0 ]; then
    breaklength=$length_seconds_longbreak
  else
    breaklength=$length_seconds_shortbreak
  fi
  if [ "$minimal_mode" = true ]; then
    printf 'Break #%d?\r' $cycle_current
  else
    printf 'Press any key to start break...\r'
  fi
  read -n1 -s
  timer_display $breaklength "Break #${cycle_current}"
  play "$sound_timeup" &> /dev/null &

  cycle_current=$((cycle_current+1))
done
