# -*- coding: utf-8 -*-
"""some helper functions:"""

import re
from math import log, pow

from microcsound.constants import MIDDLE_C_HZ


def octaves(pitch):
    """Return a value in log octaves of a pitch expressed as a decimal."""
    return log(pitch, 2)


def solfege2et(text, div):
    """Translate an traditional "abcdefg" plus accidentals notation
    into numerical form. "div" represents the division of the octave
    we are working with. Mostly, this is useful in meantone tuning systems,
    or systems that have some connection to chains-of-perfect-fifths, so that
    diatonic note distances have meaningful mappings to numeric values. I.E.,
    There are some systems where it is simply better to use note-number indices
    to indicate pitch, because they are far enough removed from the diatonic
    system to make traditional 'a-g' letter names useful.

    :param text:  the input string with note, accidental, and octave tokens
    :type text: `str`
    :param div: the integer or float value representing the division of the
                octave being used. Just intonation can be arbitrarily-closely
                simulated by using a large-enough value, e.g. 1200000
    :type div: `int` or `float`
    :returns: an integer representing a degree in an octave or non-octave
              based tuning system.
    :rtype: `int`

    :Example:

    >>> solfege2et('^g', 19)
    >>> 12
    """
    # some helper definitions:
    octav = int(round(div))
    tempered_fifth = round(octaves(1.5) * div)
    whole_step = 2 * tempered_fifth % div
    chromatic = (3 * whole_step) - ((-1 * tempered_fifth) % div)
    half_chromatic = chromatic * 0.5
    syntonic = round(octaves(81 / 80.0) * div)
    septimal = round(octaves(64 / 63.0) * div)
    undecimal = round(octaves(33 / 32.0) * div)
    tridecimal = round(octaves(1053 / 1024.0) * div)
    # extra:
    pure_fifth = octaves(1.5) * div
    meancomma = pure_fifth - tempered_fifth

    # the notes tokens:
    note_tokens = {
        "=": 0,
        "c": 0,
        "d": whole_step,
        "e": whole_step * 2,
        "f": (-1 * tempered_fifth) % div,
        "g": tempered_fifth,
        "a": tempered_fifth + whole_step,
        "b": tempered_fifth + whole_step * 2,
        "^": chromatic,
        "_": -1 * chromatic,
        "^/2": half_chromatic,
        "_/2": -1 * half_chromatic,
        "/": syntonic,
        "\\": -1 * syntonic,
        ">": septimal,
        "<": -1 * septimal,
        "!": undecimal,
        "¡": -1 * undecimal,
        "?": tridecimal,
        "¿": -1 * tridecimal,
        "*": meancomma,
        "'": octav,
        ",": -1 * octav,
    }

    # a place to collect the total:
    value_sum = 0

    for intok in re.findall(r"\^/2|_/2|[a-g',^_=/\\<>!?]|\xc2\xa1|\xc2\xbf|\*", text):
        value_sum += note_tokens[intok]

    # return the result:
    return int(value_sum)


def degree2hz(degree, div):
    """Return a pitch in Hz from a numeric index & division of the octave.

    Think of the 'degree' as the numerator, and the 'div' as the denominator
    of a fraction that represents a _logarithmic_ (base-2) ratio.  The
    returned value is the vibrations-per-second in HZ for that given pitch.

    :param degree: The degree of the octave (numerator)
    :type degree: `int` (or `float`, if that's useful)
    :param div: The division of the octave (denominator)
    :type div: `int` (or `float` for non-octave based divisions.
    :returns: A number that represents the HZ pitch
    :rtype: `float`
    """
    myhz = MIDDLE_C_HZ * pow(2, (degree + 0.0) / div)
    return "%1.5f" % myhz
