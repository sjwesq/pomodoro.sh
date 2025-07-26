pomodoro.sh
=====
A simple pomodoro timer designed to be left running in a terminal window. It
provides features inspired by [Solanum](https://apps.gnome.org/Solanum/): the
timer can be paused at any time, and each stage of the cycle can be skipped
using the `s` key. Like Solanum, it waits for user input before starting the
next stage in each cycle.

The timer is designed to be easily be scaled to small sizes -- with the `-m`
flag, the terminal can safely be scaled to be as small as 20 columns by 1 row.

Two sound files are included. They have been sourced from a royalty-free sound
site. If you are the owner and would like them removed, please contact me.

The `sox` package is required for notification sounds (the script uses the
`play` command.)

Here is the output of `./pomodoro.sh -h`:
```
Usage: ./pomodoro.sh [OPTION]...
Displays a simple configurable pomodoro timer.
Example: ./pomodoro.sh -p 20 -c 2 -n ~/Music/bell.mp3

  -h	Displays this (h)elp screen

  -m	Toggles (m)ini mode - designed for small terminal windows

  -w	Enables black-and-(w)hite output mode (disables color)

  -p	Length of (p)omodoros in minutes (default 25)
  -b	Length of (b)reaks in minutes (default 5)
  -l	Length of (l)ong breaks in minutes (default 20)

  -c	Current pomodoro (c)ycle (default 1)
  -i	(i)nterval for how often long breaks are given (default 4)

  -n	Location of pomodoro-end (n)otification sound file
  -t	Location of break (t)ime-up sound file
```
