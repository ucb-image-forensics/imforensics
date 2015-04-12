from __future__ import absolute_import
from __future__ import division

import numpy as np

from sys import stdout

def rgb2gray(rgb):
    return np.dot(rgb[:, :, :3], [0.299, 0.587, 0.144])

def iterate_with_progress(collections):
    cursor = '.'
    last_percent = -1
    length = len(collections)

    for index, item in enumerate(collections):
        cur_percent = int(100.0 * (index+1) / length)
        if cur_percent > last_percent:
            last_percent = cur_percent
            stdout.write('\r' + cursor * cur_percent + " %d%%" % cur_percent)
            if cur_percent == 100:
                stdout.write('\n')
            stdout.flush()
        yield item
