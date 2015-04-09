from datetime import datetime, timedelta

from PIL import Image
from PIL import ExifTags

Image.MAX_IMAGE_PIXELS = None
INV_TAGS = dict((v, k) for k, v in ExifTags.TAGS.iteritems())


class ExifExtractor(object):

    def __init__(self, image_path):
        self.exif = Image.open(image_path)._getexif()

    def extract(self):
        """
        Return the exif data of the image.

        :param image: a PIL image
        :return: an object of exif features
        """
        exif_data = {
            'camera': self.camera_exif,
            'software': self.software_exif,
            'timestamp': self.timestamp_exif
        }
        return exif_data

    @property
    def camera_exif(self):
        """
        Return the exif data associated with cameras
        :param exif: a PIL formatted EXIF dict
        :return: a dict of features as strings
        """

        tags = [
            'ExifImageHeight',
            'ExifImageWidth',
            'ExifOffset',
            'FNumber',
            'Flash',
            'FocalLength',
            'ISOSpeedRatings',
            'Make',
            'MeteringMode',
            'Model',
            'SceneCaptureType',
            'WhiteBalance',
        ]
        return self.get_tags(self.exif, tags)

    @property
    def timestamp_exif(self):
        """
        Return the exif data associated with timestamps
        :param exif: a PIL formatted EXIF dict
        :return: a dict of features as datetimes
        """

        tags = [
            'DateTimeOriginal',
            'DateTimeDigitized',
            'DateTime'
        ]
        return self.get_tags(self.exif, tags, ExifExtractor.format_date)

    @property
    def software_exif(self):
        """
        These are features that I found that tend to
        be written to by software that may be manipulating
        images.
        :param exif: a PIL formatted EXIF dict
        :return: a dict of features as strings
        """

        tags = [
            'Software',
            'FlashPixVersion',  # Comes from smartphones and software
            'ColorSpace',  # Uncalibrated for software
        ]
        return self.get_tags(self.exif, tags, str)

    def get_tags(self, exif, tags, format=repr):
        """
        Extracts the exif values given a list
        of tags
        :param exif: a PIL formatted EXIF dict
        :param tags: a list of names of exiftags
        to extract. Use PIL ExifTag names
        :param format: a formatter for the individual
        exif value (default: repr)
        :return: a dict of features as strings
        """

        tags_dict = {}
        for tag in tags:
            tags_dict[tag] = self.get_tag(self.exif, tag, format)
        return tags_dict

    def get_tag(self, exif, tag, format=repr):
        """
        Extracts the exif value given a PIL ExifTag
        name
        :param exif: a PIL formatted EXIF dict
        :param tag: the name of the tag
        :param format: a formatter for the exif value
        (default: repr)
        :return: the tag value
        """

        try:
            tag_id = INV_TAGS[tag]
            tag_val = exif[tag_id]
            return tag_val
        except KeyError:  # Exif field missing
            return None
        except TypeError:  # No exif data with img, is None
            return None

    @staticmethod
    def format_date(datestring):
        """
        Parses an exif datetime string as a python
        datetime object. The input format is
        "YYYY:MM:DD HH:MM:SS"
        :param format: an exif datetime string
        :return: a datetime object corresponding to
        the input. None give you a future date which
        will make computing features easier.
        """
        try:
            return datetime.strptime(datestring, "%Y:%m:%d %H:%M:%S")
        except (ValueError, TypeError):  # Malformed or None
            return datetime.utcnow() + timedelta(1)
