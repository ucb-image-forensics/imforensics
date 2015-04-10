from imforensics.metadata.exif import ExifExtractor

from PIL import Image

Image.MAX_IMAGE_PIXELS = None


class ExifReport(object):

    """ Class encapsulating Exif Report."""

    def __init__(self, image_path):
        extractor = ExifExtractor(image_path)
        self.exif_data = extractor.extract()
        self.w, self.h = Image.open(image_path).size

    def process(self):
        return {
            'im': {
                'width': self.w,
                'height': self.h,
            },
            'results': {
                'has_software_manipulation': self.has_software_modification,
                'has_camera_attrs': self.has_all_camera_info and self.has_all_datetime_attributes,
                'has_size_mismatch': self.has_exif_size_mismatch,
                'has_crop_resize': self.is_cropped_or_resized,
            },
            'exif': self.exif_data,
        }

    @property
    def has_all_datetime_attributes(self):
        """Returns True if all datetime attributes that we expect are there."""
        for key, value in self.exif_data['timestamp'].items():
            if value is None:
                return False
        return True

    @property
    def has_software_modification(self):
        """Returns True if we detect a software modification."""
        if 'Software' not in self.exif_data['software'] or not self.exif_data['software']['Software']:
            return False
        software = self.exif_data['software']['Software'].lower()
        known_software_strings = ['photoshop', 'adobe', 'gimp']

        found = sum([int(s in software) for s in known_software_strings])
        return found > 0

    @property
    def has_exif_size_mismatch(self):
        """Return True if size of image mismatches exif size."""

        ex_h = self.exif_data['camera']['ExifImageHeight']
        ex_w = self.exif_data['camera']['ExifImageWidth']
        if not (ex_h and ex_w):
            return False
        return not (self.w == ex_w and self.h == ex_h)

    @property
    def is_cropped_or_resized(self):
        """Return True if image has been resized or cropped."""
        return not (self.w % 8 == 0 and self.h % 8 == 0)

    @property
    def has_all_camera_info(self):
        """Return True if it has all the camera info we expect."""
        for key, value in self.exif_data['camera'].items():
            if value is None:
                return False
        return True
