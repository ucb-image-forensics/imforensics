from __future__ import absolute_import

import numpy as np

class BasicMetricsELA(object):

    def __init__(self, ela):
        self.ela_image_data = ela.ela_data
        self.generate_metrics()

    def generate_metrics(self):
        ela_image_data_r = self.ela_image_data[:, :, 0]
        r_mean = np.mean(ela_image_data_r)
        r_median = np.median(ela_image_data_r)
        r_var = np.var(ela_image_data_r)

        ela_image_data_g = self.ela_image_data[:, :, 1]
        g_mean = np.mean(ela_image_data_g)
        g_median = np.median(ela_image_data_g)
        g_var = np.var(ela_image_data_g)

        ela_image_data_b = self.ela_image_data[:, :, 2]
        b_mean = np.mean(ela_image_data_b)
        b_median = np.median(ela_image_data_b)
        b_var = np.var(ela_image_data_b)

        self.metrics = (
            r_mean, r_median, r_var,
            g_mean, g_median, g_var,
            b_mean, b_median, b_var,
        )

    @property
    def aggregate_variance(self):
        return (
            self.metrics[2] + self.metrics[5] + self.metrics[8]
        )

    @property
    def aggregate_mean(self):
        return (
            self.metrics[0] + self.metrics[3] + self.metrics[6]
        )
