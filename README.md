pomodoro.sh
=====
A simple pomodoro timer, designed to be left running in a terminal window.
Inspired by [Solanum](https://apps.gnome.org/Solanum/), you are able to pause
the timer at any time, or skip to the next stage of the cycle (using the `s`
key.) It uses `play` from the `sox` package in order to play notification sounds
at the end of each time interval, therefore `sox` can be considered to be
required.

You can comfortably scale it down to small sizes, but you'll want to use the
`-m` flag for anything under 80 columns. Generally, under 80 columns is not
really defined properly, but I had good results when I tried it.

Two sound files are included -- I downloaded them from a royalty-free sound
site. I don't own them. If you are the owner and this is problematic, please
contact me.

Here is the output of `./pomodoro.sh -h`:
```
Usage: ./pomodoro.sh [OPTION]...
Displays a simple configurable pomodoro timer.
Example: ./pomodoro.sh -p 20 -c 2 -n ~/Music/bell.mp3

  -h	Displays this (h)elp screen

  -m	Toggles (m)ini mode - designed for small terminals

  -p	Length of (p)omodoros in minutes (default 25)
  -b	Length of (b)reaks in minutes (default 5)
  -l	Length of (l)ong breaks in minutes (default 15)

  -c	Current pomodoro (c)ycle (default 1)
  -i	(i)nterval for how often long breaks are given (default 4)

  -n	Location of pomodoro-end (n)otification sound file
  -t	Location of break (t)ime-up sound file
```
