from __future__ import absolute_import

import os.path as op

class CopyMoveDetector(object):

    def __init__(self, matlab_engine):
        self.matlab_engine = matlab_engine
        ml_path = op.join(op.dirname(op.realpath(__file__)), 'matlab')
        self.matlab_engine.addpath(ml_path)

    def detect(self, img_file):
        result = self.matlab_engine.copymove_detector(img_file)
        ransac_img = result['ransac_img']
        ransac_matches = self._parse_matches(result['ransac_matches'])
        return ransac_img, ransac_matches

    def _parse_matches(self, matches):
        parsed = {}
        parsed['source'] = self._parse_points(matches['source'])
        parsed['target'] = self._parse_points(matches['target'])
        return parsed

    def _parse_points(self, points):
        return [{'x':p[1], 'y':p[0]} for p in points]
