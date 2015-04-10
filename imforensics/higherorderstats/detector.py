from __future__ import absolute_import

import os.path as op

class HigherOrderStatsDetector(object):

    def __init__(self, matlab_engine):
        self.matlab_engine = matlab_engine
        ml_path = op.join(op.dirname(op.realpath(__file__)), 'matlab')
        self.matlab_engine.addpath(ml_path)
