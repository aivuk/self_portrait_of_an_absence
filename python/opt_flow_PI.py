#!/usr/bin/env python
from __future__ import print_function
import sys

#Computer vision
import cv2
import numpy as np
import picamera
import picamera.array

#OSC
import socket
from txosc import osc
from txosc import sync

pygameMode = True
if len(sys.argv) > 1:
    pygameMode = False

if pygameMode:
    import pygame

    pygame.init()

    pygame.display.set_caption("OpenCV camera stream on Pygame")
    screen_width = 320
    screen_height = 240

    screen = pygame.display.set_mode([screen_width, screen_height])

#OSC SC client
oscClient = sync.UdpSender("localhost",57120)

camera = picamera.PiCamera()
camera.resolution = (320, 240)
camera.framerate = 18
# set up a video stream
video = picamera.array.PiRGBArray(camera)

# set up pygame, the library for displaying images
def draw_flow(img, flow, step=16):
    h, w = img.shape[:2]
    y, x = np.mgrid[step/2:h:step, step/2:w:step].reshape(2,-1).astype(int)
    fx, fy = flow[y,x].T
    lines = np.vstack([x, y, x+fx, y+fy]).T.reshape(-1, 2, 2)
    lines = np.int32(lines + 0.5)
    vis = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    cv2.polylines(vis, lines, 0, (255, 0,0))
    for (x1, y1), (x2, y2) in lines:
        cv2.circle(vis, (x1, y1), 1, (0, 255, 0), -1)
    h, w, _ = flow.shape
    left_eye = np.apply_along_axis(np.linalg.norm, 0, flow[:,:w/2]).mean()
    right_eye = np.apply_along_axis(np.linalg.norm, 0, flow[:,w/2:]).mean()
    diff = (left_eye - right_eye)
    if pygameMode:
        print(diff)
    if abs(diff)>1:
        msg = osc.Message("/secondSound")
        detune = float(abs(diff)/10) #detune
        rate = float(abs(diff)/10)) #rate
        msg.add(detune)
        msg.add(rate)
        oscClient.send(msg)
    return vis

try:
    camera.capture(video, format="bgr", use_video_port=True)
    prevgray = cv2.cvtColor(video.array, cv2.COLOR_BGR2GRAY)
    video.truncate(0)

    for frameBuf in camera.capture_continuous(video, format ="bgr", use_video_port=True):
        # convert color and orientation from openCV format to GRAYSCALE
        video.truncate(0)
        gray = cv2.cvtColor(frameBuf.array, cv2.COLOR_BGR2GRAY)

        flow = cv2.calcOpticalFlowFarneback(prevgray, gray, pyr_scale=0.5, levels=3, winsize=15, iterations=3, poly_n=5, poly_sigma=1.2, flags=cv2.OPTFLOW_USE_INITIAL_FLOW)
        prevgray = gray
        flow_im = np.fliplr(np.rot90(draw_flow(gray, flow)))
        if pygameMode:
            surface = pygame.surfarray.make_surface(flow_im)
            screen.fill([0,0,0])
            screen.blit(surface, (0,0))
            pygame.display.update()

            for event in pygame.event.get():
                if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                    raise SystemExit


# this is some magic code that detects when user hits ctrl-c (and stops the programme)
except KeyboardInterrupt,SystemExit:
    if pygameMode:
        pygame.quit()
        cv2.destroyAllWindows()
    sys.exit(0)
