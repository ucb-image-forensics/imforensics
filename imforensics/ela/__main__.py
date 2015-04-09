from __future__ import absolute_import

from .ela import ELA
from .metrics import BasicMetricsELA
from .util import iterate_with_progress

import numpy as np
import scipy.io as sio

import sys, os

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
    generate_raw_data(directory, 'output.mat')

if __name__ == '__main__':
    main()
