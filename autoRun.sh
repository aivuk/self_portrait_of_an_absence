#!/bin/bash
#must be on ~/ .baschrc
#using standalone version of Supercolider
export DISPLAY=:0.0
export `dbus-launch | grep ADDRESS`
export `dbus-launch | grep PID`
jackd -P95 -dalsa -dhw:0 -p1024 -n3 -s -r44100 &
cd supercolliderStandaloneRPI2 #needs SC standalone version
xvfb-run --auto-servernum ./sclang -a -l sclang.yaml main_script.scd #main supercollider script
