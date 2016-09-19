#!/usr/bin/python
import socket
from txosc import osc
from txosc import sync
import time
import sys

client = sync.UdpSender("localhost",57120)

for i in range(100):
    msg = osc.Message("/secondSound")
    msg.add(i/100.0) #deviation
    msg.add(1) #rate
    time.sleep(0.2)
    client.send(msg)
    print(i)



