#!/usr/bin/python

from setuptools import setup, find_packages
from os import path

setup(
    name="microcsound",
    version="2017.0929",
    description=('A tool for writing csound scores that can handle ' + 
                 'microtonality quite well!'),
    author='Aaron Krister Johnson',
    author_email='akjmicro@gmail.com',
    url='untwelve.org/microcsound',
        
    packages=find_packages(),
    package_data={
        '': ['share/data/*', 'share/doc/*']
    },
    entry_points={
        'console_scripts': [
            'microcsound=microcsound.main:main',
        ],
    }    
)
