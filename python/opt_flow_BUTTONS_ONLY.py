#!/usr/bin/env python
from __future__ import print_function
import sys
import time

#RaspberryPi Buttons
import RPi.GPIO as GPIO

#OSC
import socket
from txosc import osc
from txosc import sync

#Configure buttons
GPIO.setmode(GPIO.BCM)
GPIO.setup(26, GPIO.IN)
GPIO.setup(19, GPIO.IN)
GPIO.setup(13, GPIO.IN)
GPIO.setup(6, GPIO.IN)

#OSC SC client
oscClient = sync.UdpSender("localhost",57120)

button1 = 0
button2 = 0
button3 = 0
button4 = 0

while True:
    button1 = GPIO.input(26)
    button2 = GPIO.input(19)
    button3 = GPIO.input(13)
    button4 = GPIO.input(6)

    print(button1, button2, button3, button4)
    msg = osc.Message("/secondSound")
    #detune = float(abs(diff)/10) #detune
    #rate = 5 + 14*eyes_cosine
    #msg.add(button1)
    #msg.add(rate)
    #oscClient.send(msg)
 
    time.sleep(0.2)

