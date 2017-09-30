# -*- coding: utf-8 -*-
#### some helper functions:

import re
from math import log, pow

from microcsound.constants import MIDDLE_C_HZ


def octaves(pitch):
    """return a value in log octaves of a pitch expressed as a decimal"""
    return log(pitch, 2)


def solfege2et(text, div):
    ''' translate an traditional "abcdefg" plus accidentals notation
    into numerical form. "div" represents the division of the octave
    we are working with. '''

    ### some helper definitions:
    octav = int(round(div))    
    tempered_fifth = round(octaves(1.5) * div)
    whole_step = 2 * tempered_fifth % div
    chromatic = (3 * whole_step) - \
                ((-1 * tempered_fifth) % div)
    half_chromatic = chromatic * .5
    syntonic = round(octaves(81/80.0) * div)
    septimal = round(octaves(64/63.0) * div)
    undecimal = round(octaves(33/32.0) * div)
    tridecimal = round(octaves(1053/1024.0) * div)
    ### extra: ###
    pure_fifth = octaves(1.5) * div
    meancomma = pure_fifth - tempered_fifth

    ### the notes:
    notes = {'=': 0,
             'c': 0,
             'd': whole_step,
             'e': whole_step * 2,
             'f': (-1 * tempered_fifth) % div,
             'g': tempered_fifth,
             'a': tempered_fifth + whole_step,
             'b': tempered_fifth + whole_step * 2,
             '^': chromatic,
             '_': -1 * chromatic,
             '^/2': half_chromatic,
             '_/2': -1 * half_chromatic,
             '/':  syntonic,
             '\\': -1 * syntonic,
             '>': septimal,
             '<': -1 * septimal,
             '!': undecimal,
             '¡': -1 * undecimal,
             '?': tridecimal,
             '¿': -1 * tridecimal,
             '*': meancomma,
             "'": octav,
             ",": -1 * octav
            }

    # a place to collect the total:
    value_sum = 0

    for i in re.findall(r"\^/2|_/2|[a-g',^_=/\\<>!?]|\xc2\xa1|\xc2\xbf|\*",
                        text):
        value_sum += notes[i]

    ### return the result:
    return int(value_sum)


def degree2hz(degree, div):
    """return a pitch in HZ from a numerical index
    and a division of the octave"""

    myhz = MIDDLE_C_HZ * pow(2, (degree + 0.0)/div)
    return "%1.5f" % myhz
