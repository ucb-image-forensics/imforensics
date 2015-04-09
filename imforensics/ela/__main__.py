from __future__ import absolute_import

from .ela import ELA
from .metrics import BasicMetricsELA
from .util import iterate_with_progress

import numpy as np
import scipy.io as sio

import sys, os

def main():
    directory = sys.argv[1]
    raw_basic_metrics = np.empty([0, 9])
    aggregate_metrics = np.empty([0, 2])

    for filename in iterate_with_progress(os.listdir(directory)):
        ela = ELA(os.path.join(directory, filename))

        metrics = BasicMetricsELA(ela)
        raw_basic_metrics = np.append(raw_basic_metrics,
            np.array([metrics.metrics]), axis=0)
        aggregate_metrics = np.append(aggregate_metrics,
            [[metrics.aggregate_mean, metrics.aggregate_variance]], axis=0)

    output = {
        'raw_basic_metrics': raw_basic_metrics,
        'aggregate_metrics': aggregate_metrics
    }

    sio.savemat(os.path.join(directory, 'output.mat'), output)

if __name__ == '__main__':
    main()
