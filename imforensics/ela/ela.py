from __future__ import absolute_import

import os

import numpy as np
from PIL import Image, ImageChops, ImageEnhance
from scipy.misc import imsave
from scipy.ndimage.filters import gaussian_filter

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
    def ela_data(self):
        return self._ela_data

    @property
    def image_data(self):
        return self._image_data

    @property
    def image_data_gray_scale(self):
        if not hasattr(self, '_image_data_gray_scale'):
            self._image_data_gray_scale = rgb2gray(self._image_data)
        return self._image_data_gray_scale

    @property
    def ela_image_scaled(self):
        if not hasattr(self, '_ela_image_scaled'):
            extrema = self._ela_image.getextrema()
            max_diff = max([ex[1] for ex in extrema])
            scale = 255.0/(max_diff*0.8)
            scaled_im = ImageEnhance.Brightness(self._ela_image).enhance(scale)
            self._ela_image_scaled = np.array(scaled_im)
        return self._ela_image_scaled

    @property
    def low_freq_mask(self):
        if not hasattr(self, '_low_freq_mask'):
            low_passed = gaussian_filter(self.image_data_gray_scale, 5)
            abs_diff = np.abs(self.image_data_gray_scale - low_passed)
            clipped = abs_diff * (abs_diff < np.percentile(abs_diff, 23))
            scaled = clipped * (255.0 / np.max(clipped))
            blurred = gaussian_filter(scaled, 10)
            self._low_freq_mask = \
                ((blurred > np.percentile(blurred, 50)) * 64).astype(np.uint8)
        return self._low_freq_mask

    @property
    def ela_mask(self):
        if not hasattr(self, '_ela_mask'):
            ela_data_magnitude = np.sqrt(self.ela_data[:, :, 0]**2 +
                                         self.ela_data[:, :, 1]**2 +
                                         self.ela_data[:, :, 2]**2)
            ela_mask = (ela_data_magnitude > np.percentile(ela_data_magnitude, 90))\
                       .astype(np.uint8) * ela_data_magnitude
            ela_mask = gaussian_filter(ela_mask, 10)
            ela_mask = ela_mask * (255.0 / np.max(ela_mask))
            self._ela_mask = ((ela_mask > np.percentile(ela_mask, 70)) * 128)\
                .astype(np.uint8)
        return self._ela_mask

    def save_suspect_region(self):
        # Create input image with opaque alpha channel.
        given_image = self._image.copy()
        given_image.putalpha(Image.new('L', given_image.size, color=255))

        # Create ela mask image.
        ela_mask_alpha = Image.fromarray(self.ela_mask).convert('L')
        ela_mask_image = Image.merge('RGBA', [Image.new('L', ela_mask_alpha.size, color=255),
                                              Image.new('L', ela_mask_alpha.size, color=0),
                                              Image.new('L', ela_mask_alpha.size, color=0),
                                              ela_mask_alpha])

        # Create low freq mask image.
        low_freq_mask_alpha = Image.fromarray(self.low_freq_mask).convert('L')
        low_freq_mask_image = Image.merge('RGBA', [Image.new('L', low_freq_mask_alpha.size, color=0),
                                                   Image.new('L', low_freq_mask_alpha.size, color=0),
                                                   Image.new('L', low_freq_mask_alpha.size, color=255),
                                                   low_freq_mask_alpha])

        # Create combined mask.
        combined_mask = Image.alpha_composite(ela_mask_image, low_freq_mask_image)

        # Put mask on image.
        Image.alpha_composite(given_image, combined_mask)\
             .save('{0}.ela_suspect.jpeg'.format(self.filename),
                   format='JPEG')

    def save_ela_image(self):
        imsave('{0}.ela.png'.format(self.filename),
                self.ela_image_scaled)

    def _run_ela(self):
        self._resave_first_image()
        self._resave_image()
        self._ela_image = ImageChops.difference(self._image, self._resaved_image)
        self._ela_data = np.array(self._ela_image)

    def _resave_image(self):
        resaved = self.filename + '.resaved.jpg'
        self._image.save(resaved, 'JPEG', quality=self.resave_quality)
        self._resaved_image = Image.open(resaved)
        os.remove(resaved)

    def _resave_first_image(self):
        resaved = self.filename + '.r1.jpg'
        Image.open(self.filename).save(resaved, 'JPEG', quality=100)
        self._image = Image.open(resaved)
        self._image_data = np.array(self._image)
        os.remove(resaved)
