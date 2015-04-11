from __future__ import absolute_import

import imghdr

def is_jpeg(img_path):
    return imghdr.what(img_path) == 'jpeg'
