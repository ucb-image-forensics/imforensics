from __future__ import absolute_import

import os.path as op

from sklearn.externals import joblib

from ..metrics import BasicMetricsELA

class ELAClassifier(object):
    SERIALIZED_FILE = op.join(op.dirname(op.realpath(__file__)),
                              'ela_classifier/ela_classifier.pkl')

    P1D0 = -0.00225
    P2D0 = 0.01015
    N1D0 = -0.02704
    N2D0 = -0.03943
    M0   = -0.01464
    P1D1 = 0.01264
    P2D1 = 0.0195
    N1D1 = -0.00107
    N2D1 = -0.00793
    M1   = 0.00578

    SURE_AUTH_MSG = "The image is surely authentic."
    NOT_SURE_AUTH_MSG = "The image may be authentic."
    NOT_SURE_FAKE_MSG = "The image may be manipulated."
    SURE_FAKE_MSG = "The image is surely manipulated."

    SURE_AUTH_FLAG = 0
    NOT_SURE_AUTH_FLAG = 1
    NOT_SURE_FAKE_FLAG = 2
    SURE_FAKE_FLAG = 3

    def __init__(self):
        self.classifier = joblib.load(ELAClassifier.SERIALIZED_FILE)

    def predict(self, ela):
        feature = self._build_feature(ela)
        return bool(self.classifier.predict(feature)[0])

    def decision_function(self, ela):
        feature = self._build_feature(ela)
        return self.classifier.decision_function(feature)[0]

    def predict_message(self, ela):
        score = self.decision_function(ela)
        if score < ELAClassifier.N2D1:
            return ELAClassifier.SURE_AUTH_MSG
        elif score < 0.0:
            return ELAClassifier.NOT_SURE_AUTH_MSG
        elif score < ELAClassifier.P1D1:
            return ELAClassifier.NOT_SURE_FAKE_MSG
        else:
            return ELAClassifier.SURE_FAKE_MSG

    def predict_flag(self, ela):
        score = self.decision_function(ela)
        print score
        if score < ELAClassifier.N2D1:
            return ELAClassifier.SURE_AUTH_FLAG
        elif score < 0.0:
            return ELAClassifier.NOT_SURE_AUTH_FLAG
        elif score < ELAClassifier.P1D1:
            return ELAClassifier.NOT_SURE_FAKE_FLAG
        else:
            return ELAClassifier.SURE_FAKE_FLAG

    def _build_feature(self, ela):
        metrics = BasicMetricsELA(ela)
        raw_basic_metrics = list(metrics.metrics)
        aggregate_metrics = [metrics.aggregate_mean, metrics.aggregate_variance]
        feature = raw_basic_metrics + aggregate_metrics
        return feature
