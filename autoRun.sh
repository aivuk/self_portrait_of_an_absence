#!/bin/bash
#must be on ~/ .baschrc
#using standalone version of Supercolider
SCDIR = /home/pi/supercolliderStandaloneRPI2 #sc dir
SCFILE = /home/pi/self_portrait_of_an_absence/scscripts/graziele_firstTestsEyetrackingSounds.scd
PYTHONF = /home/pi/self_portrait_of_an_absence/python/opt_flow_PI.py
export DISPLAY=:0.0
export `dbus-launch | grep ADDRESS`
export `dbus-launch | grep PID`
jackd -P95 -dalsa -dhw:0 -p1024 -n3 -s -r44100 &
python PYTHONF 0 &
xvfb-run --auto-servernum SCDIR/sclang -a -l SCDIR/sclang.yaml SCFILE #main supercollider script
