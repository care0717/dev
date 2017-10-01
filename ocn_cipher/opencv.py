# -*- coding: utf-8 -*-

import cv2
import numpy as np
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt

img = cv2.imread('sample.png', 0)
ret, thresh1 = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
height, width = thresh1.shape
print(height,width)


def get_black_part_indexs(img):
    res = []
    before_v = img[0]
    temp = []
    for i,value in enumerate(img):
        if(value != before_v):
            temp.append(i)
            before_v = value
        if(len(temp) == 2):
            res.append(temp)
            temp = []
    return res

def get_black_part(img, img_1d):
    indexs = get_black_part_indexs(img_1d)
    res = []
    for index in indexs:
        res.append(img[:, index[0]:index[1]])
    return res


def split(img):
    img_1d = img.T.min(axis = 1)
    return get_black_part(img, img_1d)


for i in split(thresh1):
    print(i)
