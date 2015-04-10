from __future__ import absolute_import

import os.path as op

class HigherOrderStatsDetector(object):

    def __init__(self, matlab_engine):
        self.matlab_engine = matlab_engine
        ml_path = op.join(op.dirname(op.realpath(__file__)), 'matlab')
        self.matlab_engine.addpath(self.matlab_engine.genpath(ml_path))

    def detect(self, img_file):
        return self.matlab_engine.hos_detector(img_file)
