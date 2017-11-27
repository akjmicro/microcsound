from readline import *
from sys import stdin, stdout, argv
from os import system
import re
import argparse

try:
    from StringIO import StringIO
except:
    from io import StringIO

from microcsound import constants
from microcsound.parser import parser, PARSER_PATTERN
from microcsound.state import state_obj
from microcsound.main import (live_loop_in, process_buffer)


def sanity_tests():
    ''' runs some tests before execution... '''

    ##### test the regex pattern detection:
    test_string_1 = '''div=31 gr=0.8[L:1/4] i=17
     "2%3%.02%3%0.001%.1%.02%.5%0.001%.1%8000%.1%440%-1.2%-1.2%.001%.002"
     gf.g2.f2 p12=0.002 21 1/4 r3 @0.5 _e2 t t t t tt 4.18 [_e' _d''] '''
    try:
        assert len(PARSER_PATTERN.findall(test_string_1)) == 20
    except:
        print(PARSER_PATTERN.findall(test_string_1))

    test_string_2 = '''[4.8 5.6 6.2] 15  tt 1/4 t t=80 .c4 -13 1/4 8. e3
    | e 6.12 &4 1/16 c'16 &-15 ^^f15 &-14 ^a14 &-13 ^d13 &-12 z2 ^d,, 12'''
    assert len(PARSER_PATTERN.findall(test_string_2)) == 28

    test_string_3 = '1/8 PD10 5.4 0 3 2 1 6 5 7 PU @4f 4.4 @F @5'
    assert len(PARSER_PATTERN.findall(test_string_3)) == 15
    
    ## now test the live looper function. We use a mock input via a StringIO
    ## object instead of 'raw_input', which requires human intervention.    
    my_test_string = "1: i=7 t=60 div=17\n1: c d e f g'\ndone\n"
    fp = StringIO(my_test_string)
    result = live_loop_in(fp)
    result_2 = process_buffer(result, rt_mode=True)
    assert 'i200 0 -1\ni7.0 0.000 0.250  0.66  261.62557  0.5  1  \n' \
           'i7.0 0.250 0.250  0.66  295.66718  0.5  1  \n' \
           'i7.0 0.500 0.250  0.66  334.13815  0.5  1' \
           in result_2[1]
    # restore 'state':
    state_obj.__init__()

    basic_pedal_string = "1: div=0\n1: i=1 2/1 r 1/1 PD5 0 r 1 2 3 PU\ndone\n"
    fp = StringIO(basic_pedal_string)
    result = live_loop_in(fp)
    result_2 = process_buffer(result, rt_mode=True)
    print(result_2[1])
    assert result_2 == []
    state_obj.__init__()

if '__name__' == '__main__':
    sanity_tests()
