from __future__ import absolute_import

import os.path as op

def load_matlab_util(matlab_engine):
    ml_path = op.join(op.dirname(op.realpath(__file__)), 'matlab')
    matlab_engine.addpath(matlab_engine.genpath(ml_path))