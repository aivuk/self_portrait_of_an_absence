#!/usr/bin/env python
from __future__ import print_function

import pygame
import cv2
import numpy as np
import sys
import picamera
import picamera.array

# set up the camera
camera = picamera.PiCamera()
camera.resolution = (320, 240)
camera.framerate = 24
# set up a video stream
video = picamera.array.PiRGBArray(camera)

# set up pygame, the library for displaying images
pygame.init()
pygame.display.set_caption("OpenCV camera stream on Pygame")
# sets up window dimensions based on camera resolution
screen = pygame.display.set_mode(list(camera.resolution))

# variables for drawing onto the screen
screen_width = 320
screen_height = 240

def draw_flow(img, flow, step=16):
    h, w = img.shape[:2]
    y, x = np.mgrid[step/2:h:step, step/2:w:step].reshape(2,-1).astype(int)
    fx, fy = flow[y,x].T
    lines = np.vstack([x, y, x+fx, y+fy]).T.reshape(-1, 2, 2)
    lines = np.int32(lines + 0.5)
    vis = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    cv2.polylines(vis, lines, 0, (0, 255, 0))
    for (x1, y1), (x2, y2) in lines:
        cv2.circle(vis, (x1, y1), 1, (0, 255, 0), -1)
    h, w, _ = flow.shape
    left_eye = np.apply_along_axis(np.linalg.norm, 0, flow[:,:w/2]).mean()
    right_eye = np.apply_along_axis(np.linalg.norm, 0, flow[:,w/2:]).mean()
    print(left_eye - right_eye)
    return vis

try:
    camera.capture(video, format="rgb", use_video_port=True)
    prevgray = np.rot90(np.fliplr(cv2.cvtColor(video.array, cv2.COLOR_RGB2GRAY)))
    video.truncate(0)

    for frameBuf in camera.capture_continuous(video, format ="rgb", use_video_port=True):
        # convert color and orientation from openCV format to GRAYSCALE
        frame = np.rot90(np.fliplr(frameBuf.array))
        video.truncate(0)
        gray = cv2.cvtColor(frameBuf.array, cv2.COLOR_BGR2GRAY)

        flow = cv2.calcOpticalFlowFarneback(prevgray, gray, 0.5, 3, 15, 3, 5, 1.2, 0)
        prevgray = gray

        flow_im = draw_flow(gray, flow)

        surface = pygame.surfarray.make_surface(flow_im)
        screen.fill([0,0,0])
        screen.blit(surface, (0,0))
        pygame.display.update()

        # stop programme if esc key has been pressed
        for event in pygame.event.get():
            if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                raise SystemExit


# this is some magic code that detects when user hits ctrl-c (and stops the programme)
except KeyboardInterrupt,SystemExit:
    pygame.quit()
    cv2.destroyAllWindows()
    sys.exit(0)
