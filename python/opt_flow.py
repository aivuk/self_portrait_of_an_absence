#!/usr/bin/env python
from __future__ import print_function

import numpy as np
import cv2

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

    # Calculate using angle information
    left_eye_mean_velocity = flow[:,:w/2,:].sum(axis=0)
    right_eye_mean_velocity = flow[:,w/2:,:].sum(axis=0)

    left_eye_mean_velocity_norm = np.linalg.norm(left_eye_mean_velocity)
    right_eye_mean_velocity_norm = np.linalg.norm(right_eye_mean_velocity)

    eyes_cosine = left_eye_mean_velocity.dot(right_eye_mean_velocity.T)/left_eye_mean_velocity_norm*right_eye_mean_velocity_norm
    print(eyes_cosine)

    return vis

if __name__ == '__main__':

    cam = cv2.VideoCapture(0)
    cam.set(3,340)
    cam.set(4,240)
    ret, prev = cam.read()
    prevgray = cv2.cvtColor(prev, cv2.COLOR_BGR2GRAY)
    show_hsv = False
    show_glitch = False
    cur_glitch = prev.copy()

    while True:
        ret, img = cam.read()
        if ret == True:
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            flow = cv2.calcOpticalFlowFarneback(prevgray, gray, 0.5, 3, 15, 3, 5, 1.2, 0)
            prevgray = gray

            cv2.line(gray,(170 ,0),(170,240),(255,0,0),3)
            cv2.imshow('flow', draw_flow(gray, flow))
        ch = 0xFF & cv2.waitKey(5)
        if ch == 27:
            break
    cv2.destroyAllWindows()
