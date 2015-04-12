from __future__ import absolute_import

import sys
import os

import numpy as np
import scipy.io as sio

from .ela import ELA
from .metrics import BasicMetricsELA
from .util import iterate_with_progress


def generate_metrics(directory, output_file):
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
    sio.savemat(os.path.join(directory, output_file), output)

def generate_raw_data(directory, output_file):
    ela_data = np.empty((0,), dtype=object)

    for filename in iterate_with_progress(os.listdir(directory)):
        ela = ELA(os.path.join(directory, filename))
        sample = {'filename': filename,
                  'ela_image': ela.ela_image_scaled}
        ela_data = np.append(ela_data, sample)

    output = {
        'ela_data': ela_data,
    }
    sio.savemat(os.path.join(directory, output_file), output)

def main():
    directory = sys.argv[1]
    output_file = 'output.mat'
    # generate_raw_data(directory, output_file)
    generate_metrics(directory, output_file)

if __name__ == '__main__':
    main()