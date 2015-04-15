from collections import namedtuple

import numpy as np
from scipy.misc import imread, imresize


PointState = namedtuple('PointState', ['x', 'y'])

INTENSITY_THRESHOLD = 25

POSITIONS = [
    (0, 1),
    (0, -1),
    (1, 0),
    (-1, 0),
]

class Queue(object):

    def __init__(self):
        self._q = []

    def pop(self):
        return self._q.pop(0)

    def empty(self):
        return len(self._q) == 0

    def push(self, item):
        self._q.append(item)


def in_bounds(im, x, y, m):
    return (0 <= x) and (x < im.shape[0]) and (0 <= y) and (y < im.shape[1]) and (im[x, y] >= m - 20)  


def get_successors(im, state, m):
    successors = []
    for p in POSITIONS:
        x = state.x + p[0]
        y = state.y + p[1]
        if in_bounds(im, x, y, m):
            successors.append(PointState(x, y))
    return successors


def multiple_bfs(im):
    scale = float(500) / float(im.shape[0])
    im = imresize(im, scale)
    m = np.max(im)
    fringe = Queue()
    master_visited = set()
    # Need to randomly push a few random start states
    def bfs(start_state):
        visited = set()
        fringe = Queue()

        fringe.push(start_state)

        while not fringe.empty():
            state = fringe.pop()
            if state not in visited:
                successors = get_successors(im, state, m)
                visited.add(state)
                master_visited.add(state)
                for s in successors:
                    fringe.push(s)
        return visited

    # Get all locations of highest value
    max_value = np.max(im) - INTENSITY_THRESHOLD
    
    X, Y = np.where(im > max_value)
    max_blob_size = -1
    for idx in range(len(X)):
        # Get a random point from the high values to start with
        start_state = PointState(X[idx], Y[idx])
        if start_state not in master_visited:
            v = bfs(start_state)
            if len(v) > max_blob_size:
                max_blob_size = len(v)
    return max_blob_size, im.shape[0] * im.shape[1]


def find_max_blob_size(im_path):
    im = imread(im_path)
    blob_size, area = multiple_bfs(im)
    return float(blob_size) / float(area)