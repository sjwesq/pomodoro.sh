#!/bin/bash

RED=$'\033[31m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'
RESET=$'\033[0m'

################################################################################
# Function Definitions
################################################################################
clear_line() {
  cols="$(tput cols)"
  printf "%*s\r" "$((cols-1))" ""
}

wait_for_input () {
  read -n1 -s $1
}

timer_display () {
  local seconds=$1
  local label="$2"

  local seconds_formatted
  local pause
  local skip

  while [ "$seconds" -gt 0 ]; do
    clear_line
    printf -v seconds_formatted "%02d:%02d" $((seconds / 60)) $((seconds % 60))
    printf '%s %s\r' "$label" "$seconds_formatted"

    IFS= read -t1 -n1 pause # Doubles as a timer by using `-t`
    if [[ "$pause" != "" ]]; then
      clear_line
      if [[ "$minimal_mode" ]]; then
        printf "%s %s ${YELLOW}[P]${RESET}\r" "$label" "$seconds_formatted"
      else
        printf \
          '%s %s | paused - press "s" to skip or any key to continue...\r' \
          "$label" "$seconds_formatted"
      fi
      wait_for_input skip
      if [[ "$skip" = 's' ]]; then
        clear_line
        break
      fi
      # Prevents the timer from rapidly decrementing with many inputs
      seconds=$(($seconds + 1))
    fi
    seconds=$(($seconds - 1))
  done
  clear_line
}

number_check() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    printf "${RED}ERROR${RESET}: '$1' is not a valid number.\n"
    exit 1
  fi
}

require_audio() {
  soxi "$1" &>/dev/null
  if [[ "$?" != 0 ]]; then
    printf "${RED}ERROR${RESET}: '$1' is not a supported audio file.\n"
    printf "See \`play -h\` for a list of supported formats.\n"
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
require_audio "$sound_notification"
sound_timeup="$DIR/sounds/timeup.mp3"
require_audio "$sound_timeup"

while getopts 'hmwp:b:l:i:c:n:t:' OPTION; do
  case "$OPTION" in
    h)
      printf "Usage: %s [OPTION]...\n" "$0"
      printf "Displays a simple configurable pomodoro timer.\n"
      printf "Example: %s -p 20 -c 2 -n ~/Music/bell.mp3\n\n" "$0"

      printf "  -h\tDisplays this (h)elp screen\n\n"

      printf \
        "  -m\tToggles (m)ini mode - designed for small terminal windows\n\n"

      printf "  -w\tEnables black-and-(w)hite output mode (disables color)\n\n"

      printf "  -p\tLength of (p)omodoros in minutes (default %d)\n" \
        $((length_seconds_pomo/60))
      printf "  -b\tLength of (b)reaks in minutes (default %d)\n" \
        $((length_seconds_shortbreak/60))
      printf "  -l\tLength of (l)ong breaks in minutes (default %d)\n\n" \
        $((length_seconds_longbreak/60))

      printf "  -c\tCurrent pomodoro (c)ycle (default %d)\n" \
        $cycle_current
      printf \
        "  -i\t(i)nterval for how often long breaks are given (default %d)\n\n"\
        $interval_longbreak
      printf "  -n\tLocation of pomodoro-end (n)otification sound file\n"
      printf "  -t\tLocation of break (t)ime-up sound file\n"
      exit 0
      ;;
    m)
      minimal_mode=true
      ;;
    w)
      RED=""
      YELLOW=""
      CYAN=""
      RESET=""
      ;;
    p)
      # Pomodoro length (minutes)
      number_check "$OPTARG"
      length_seconds_pomo=$((OPTARG * 60))
      ;;
    b)
      # Break length (minutes)
      number_check "$OPTARG"
      length_seconds_shortbreak=$((OPTARG * 60))
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
      require_audio "$OPTARG"
      sound_notification="$OPTARG"
      ;;
    t)
      require_audio "$OPTARG"
      sound_timeup="$OPTARG"
      ;;
  esac
done

command -v play &> /dev/null || {
  printf "${YELLOW}WARNING${RESET}:"
  printf "'play' command not found. Install SoX for audio support.\n"
}

while :
do
  if [[ "$minimal_mode" = true ]]; then
    label_current="${RED}PMO${RESET}#"
  else
    printf 'Press any key to start '
    label_current='Pomodoro #'
  fi
  printf "%s%d...\r" "$label_current" $cycle_current
  wait_for_input
  timer_display $length_seconds_pomo "${label_current}${cycle_current}"
  play "$sound_notification" &> /dev/null &

  if [[ $((cycle_current % interval_longbreak)) = 0 ]]; then
    breaklength=$length_seconds_longbreak
  else
    breaklength=$length_seconds_shortbreak
  fi
  if [[ "$minimal_mode" = true ]]; then
    label_current="${CYAN}BRK${RESET}#"
  else
    printf 'Press any key to start '
    label_current='Break #'
  fi
  printf '%s%d...\r' "$label_current" $cycle_current
  wait_for_input
  timer_display $breaklength "${label_current}${cycle_current}"
  play "$sound_timeup" &> /dev/null &

  cycle_current=$((cycle_current+1))
done
