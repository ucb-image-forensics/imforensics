from __future__ import absolute_import

import os

import numpy as np
from PIL import Image, ImageChops, ImageEnhance
from scipy import ndimage
from scipy.misc import imsave

from .util import rgb2gray

class ELA(object):
    """
    ELA object that represents the error level of a given image.

    Error Level Analysis (ELA) is a method of quantifying the JPEG
    compression loss on a per pixel basis.
    """

    def __init__(self, filename, resave_quality=95):
        self.resave_quality = resave_quality
        self.filename = filename
        self._run_ela()

    @property
    def data(self):
        return self._ela_image_data

    @property
    def data_grayscale(self):
        if not hasattr(self, '_data_grayscale'):
            self._data_grayscale = rgb2gray(self._ela_image_data)
        return self._data_grayscale

    @property
    def data_one_channel(self):
        if not hasattr(self, '_data_one_channel'):
            self._data_one_channel = np.sqrt(
                    self._ela_image_data[:, :, 0]**2
                    + self._ela_image_data[:, :, 1]**2
                    + self._ela_image_data[:, :, 2]**2
                )
        return self._data_one_channel

    @property
    def mask_grayscale(self):
        if not hasattr(self, '_mask_grayscale'):
            sigma = 5
            self._mask_grayscale = ndimage.filters.gaussian_filter(self.data_grayscale,
                                                                   sigma, order=1)
        return self._mask_grayscale

    @property
    def mask_one_channel(self):
        if not hasattr(self, '_mask_one_channel'):
            sigma = 5
            self._mask_one_channel = ndimage.filters.gaussian_filter(self.data_one_channel,
                                                                     sigma, order=1)
        return self._mask_one_channel

    @property
    def combined_filter_grayscale(self):
        if not hasattr(self, '_combined_filter_grayscale'):
            masked = self.data_grayscale * self.mask_grayscale
            masked = masked.clip(min=0)
            scale = 255.0 / np.max(masked)
            self._combined_filter_grayscale = masked * scale
        return self.combined_filter_grayscale

    @property
    def combined_filter_one_channel(self):
        if not hasattr(self, '_combined_filter_one_channel'):
            masked = self.data_one_channel * self.mask_one_channel
            masked = masked.clip(min=0)
            scale = 255.0 / np.max(masked)
            self._combined_filter_one_channel = masked * scale
        return self._combined_filter_one_channel

    @property
    def ela_image_scaled(self):
        if not hasattr(self, '_ela_image_scaled'):
            extrema = self._ela_image.getextrema()
            max_diff = max([ex[1] for ex in extrema])
            scale = 255.0/(max_diff*0.8)
            scaled_im = ImageEnhance.Brightness(self._ela_image).enhance(scale)
            self._ela_image_scaled = np.array(scaled_im)
        return self._ela_image_scaled

    def save_ela_image(self):
        imsave('{0}.ela.png'.format(self.filename),
                self.ela_image_scaled)

    def _run_ela(self):
        self._resave_first_image()
        self._resave_image()
        self._ela_image = ImageChops.difference(self._image, self._resaved_image)
        self._ela_image_data = np.array(self._ela_image)

    def _resave_image(self):
        resaved = self.filename + '.resaved.jpg'
        self._image.save(resaved, 'JPEG', quality=self.resave_quality)
        self._resaved_image = Image.open(resaved)
        os.remove(resaved)

    def _resave_first_image(self):
        resaved = self.filename + '.r1.jpg'
        Image.open(self.filename).save(resaved, 'JPEG', quality=100)
        self._image = Image.open(resaved)
        os.remove(resaved)
