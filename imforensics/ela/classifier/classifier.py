from __future__ import absolute_import

import os.path as op

from sklearn.externals import joblib

from ..ela import ELA
from ..metrics import BasicMetricsELA

class ELAClassifier(object):
    SERIALIZED_FILE = op.join(op.dirname(op.realpath(__file__)),
                              'ela_classifier/ela_classifier.pkl')

    def __init__(self):
        self.classifier = joblib.load(ELAClassifier.SERIALIZED_FILE)

    def predict_with_image_path(self, image_path, raw_output=False):
        ela = ELA(image_path)
        return self.predict(ela, raw_output)

    def predict(self, ela, raw_output=False):
        feature = self._build_feature(ela)
        result = bool(self.classifier.predict(feature)[0])
        return result if raw_output else \
            'Manipulated' if result else 'Authentic'

    def _build_feature(self, ela):
        metrics = BasicMetricsELA(ela)
        raw_basic_metrics = list(metrics.metrics)
        aggregate_metrics = [metrics.aggregate_mean, metrics.aggregate_variance]
        feature = raw_basic_metrics + aggregate_metrics
        return feature
