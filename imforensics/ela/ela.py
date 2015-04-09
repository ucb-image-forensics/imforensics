from __future__ import absolute_import

import os

import numpy as np
from scipy import ndimage
from PIL import Image, ImageChops, ImageEnhance

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
        self._resave_first_image()
        self.filtered_image = None
        self.run_ela()

    @property
    def data(self):
        return self.ela_image_data

    @property
    def data_one_channel(self):
        return np.sqrt(
            self.ela_image_data[:, :, 0]**2
            + self.ela_image_data[:, :, 1]**2
            + self.ela_image_data[:, :, 2]**2
        )

    @property
    def mask(self):
        im = ndimage.imread(self.filename)
        mask = ndimage.filters.gaussian_filter(rgb2gray(self.ela_image_data), 5, order=1)
        return mask #1 / (mask + 1)

    @property
    def combined_filter_one_channel(self):
        return 50 * (rgb2gray(self.ela_image_data) ** 2) * self.mask

    @property
    def combined_filter(self):
        if self.filtered_image == None:
            self.filtered_image = np.zeros(self.ela_image_data.shape)
            self.filtered_image[:,:,0] = self.ela_image_data[:,:,0] * (self.mask ** 2)
            self.filtered_image[:,:,1] = self.ela_image_data[:,:,1] * (self.mask ** 2)
            self.filtered_image[:,:,2] = self.ela_image_data[:,:,2] * (self.mask ** 2)
        return self.filtered_image

    @property
    def combined_filter_scaled(self):
        scale = 255.0/np.max(self.combined_filter)*0.8
        return self.combined_filter * scale

    def show_ela_image(self, re_scale=True):
        if re_scale:
            extrema = self.ela_image.getextrema()
            max_diff = max([ex[1] for ex in extrema])
            scale = 255.0/(max_diff*0.8)
            ImageEnhance.Brightness(self.ela_image).enhance(scale).show()
        else:
            self.ela_image.show()

    def run_ela(self):
        self._resave_image()
        self.ela_image = ImageChops.difference(self.image, self.resaved_image)
        self.ela_image_data = np.array(self.ela_image)
        return self.ela_image_data

    def _resave_image(self):
        resaved = self.filename + '.resaved.jpg'
        self.image.save(resaved, 'JPEG', quality=self.resave_quality)
        self.resaved_image = Image.open(resaved)
        os.remove(resaved)

    def _resave_first_image(self):
        resaved = self.filename + '.r1.jpg'
        Image.open(self.filename).save(resaved, 'JPEG', quality=100)
        self.image = Image.open(resaved)
        os.remove(resaved)
