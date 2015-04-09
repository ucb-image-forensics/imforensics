#!/usr/bin/env python
from setuptools import setup, find_packages

__version__ = '0.1'


setup(
    name='imforensics',
    version=__version__,
    url='https://github.com/ucb-image-forensics/imforensics',
    packages=find_packages(),
    include_package_data=True,
)
