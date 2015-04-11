from __future__ import absolute_import

import os.path as op

class Aggregator(object):

    def __init__(self, matlab_engine):
        self.matlab_engine = matlab_engine
        ml_path = op.join(op.dirname(op.realpath(__file__)), 'matlab')
        self.matlab_engine.addpath(self.matlab_engine.genpath(ml_path))

    def aggregate(self, X_cm, X_ela, X_ho):
        return self.matlab_engine.aggregator(X_cm, X_ela, X_ho)
