#!/usr/bin/python

from setuptools import setup, find_packages
from os import path

setup(
    name="microcsound",
    version="2017.1127a1",
    description=('A tool for writing csound scores that can handle ' + 
                 'microtonality quite well!'),
    author='Aaron Krister Johnson',
    author_email='akjmicro@gmail.com',
    url='https://github.com/akjmicro/microcsound',
        
    packages=find_packages(),
    package_data={
        '': ['LICENSE.txt', 'README.md', 'README.rst',
             'share/data/*', 'share/doc/*']
    },
    entry_points={
        'console_scripts': [
            'microcsound=microcsound.main:main',
        ],
    }    
)
