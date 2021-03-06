from __future__ import absolute_import, division

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
            normalized = (self.image_data_gray_scale
                          - np.mean(self.image_data_gray_scale)) \
                         / np.std(self.image_data_gray_scale)
            low_passed = gaussian_filter(normalized, 5)
            abs_diff = np.abs(normalized - low_passed)
            clipped = (abs_diff < 0.03).astype(np.float)
            max_v = np.max(clipped)
            scaled = clipped * (255.0 / max_v) if max_v else (clipped + 255.0)
            blurred = gaussian_filter(scaled, 2)
            self._low_freq_mask = (blurred > 64).astype(np.uint8)
        return self._low_freq_mask

    @property
    def ela_mask(self):
        if not hasattr(self, '_ela_mask'):
            ela_data_magnitude = np.sqrt(self.ela_data[:, :, 0]**2 +
                                         self.ela_data[:, :, 1]**2 +
                                         self.ela_data[:, :, 2]**2)
            normalized = (ela_data_magnitude
                          - np.mean(ela_data_magnitude)) \
                         / np.std(ela_data_magnitude)
            clipped = (normalized > 0.0).astype(np.float)
            max_v = np.max(clipped)
            scaled = clipped * (255.0 / max_v) if max_v else (clipped + 255.0)
            blurred = gaussian_filter(scaled, 10)
            self._ela_mask = (blurred > np.mean(blurred)).astype(np.uint8)
        return self._ela_mask

    def save_suspect_region(self, opaque=False, show_low_freq=False, **kwargs):
        low_risk_color = kwargs.get('low_risk_color', (255, 255, 0))
        high_risk_color = kwargs.get('high_risk_color', (255, 0, 0))
        low_freq_color = kwargs.get('low_freq_color', (0, 0, 255))

        alpha = 255 if opaque else 128

        # Create input image with opaque alpha channel.
        given_image = self._image.copy()
        given_image.putalpha(Image.new('L', given_image.size, color=255))

        # Create low risk and high risk ela mask image.
        high_risk_mask = np.logical_and(self.ela_mask, self.low_freq_mask).astype(np.uint8) * alpha
        low_risk_mask = np.logical_xor(self.ela_mask, high_risk_mask).astype(np.uint8) * alpha

        low_risk_mask_alpha = Image.fromarray(low_risk_mask).convert('L')
        low_risk_mask_image = Image.new('RGB', low_risk_mask_alpha.size, color=low_risk_color)
        low_risk_mask_image.putalpha(low_risk_mask_alpha)

        high_risk_mask_alpha = Image.fromarray(high_risk_mask).convert('L')
        high_risk_mask_image = Image.new('RGB', high_risk_mask_alpha.size, color=high_risk_color)
        high_risk_mask_image.putalpha(high_risk_mask_alpha)

        # Create masked image.
        masked_image = Image.alpha_composite(given_image, low_risk_mask_image)
        masked_image = Image.alpha_composite(masked_image, high_risk_mask_image)

        # Create low freq mask image.
        if show_low_freq:
            low_freq_mask = np.logical_xor(self.low_freq_mask, high_risk_mask).astype(np.uint8) * alpha
            low_freq_mask_alpha = Image.fromarray(low_freq_mask).convert('L')
            low_freq_mask_image = Image.new('RGB', low_freq_mask_alpha.size, color=low_freq_color)
            low_freq_mask_image.putalpha(low_freq_mask_alpha)
            masked_image = Image.alpha_composite(masked_image, low_freq_mask_image)

        masked_image.save('{0}.ela_suspect.jpeg'.format(self.filename),
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
