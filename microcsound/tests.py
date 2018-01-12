import unittest
import mock

try:
    from StringIO import StringIO
except:
    from io import StringIO

import microcsound
from microcsound import constants
from microcsound.parser import parser, PARSER_PATTERN
from microcsound.state import state_obj
from microcsound.main import live_loop_in, process_buffer

def dummy_live_input_func(fp):
    def inner(prompt):
        return fp.readline()
    return inner


class MicrocsoundTests(unittest.TestCase):

    def setUp(self):
        self.old_live_input_func = microcsound.main.live_input_func

    def tearDown(self):
        state_obj.__init__()
        microcsound.main.live_input_func = self.old_live_input_func
        
    def test_parser_one(self):
        """ test the regex pattern detection"""
        test_string = '''div=31 gr=0.8[L:1/4] i=17
         "2%3%.02%3%0.001%.1%.02%.5%0.001%.1%8000%.1%440%-1.2%-1.2%.001%.002"
         gf.g2.f2 p12=0.002 21 1/4 r3 @0.5 _e2 t t t t tt 4.18 [_e' _d''] '''
        self.assertEqual(len(PARSER_PATTERN.findall(test_string)), 20)

    def test_parser_two(self):
        test_string = '''[4.8 5.6 6.2] 15  tt 1/4 t t=80 .c4 -13 1/4 8. e3
        | e 6.12 &4 1/16 c'16 &-15 ^^f15 &-14 ^a14 &-13 ^d13 &-12 z2 ^d,, 12'''
        self.assertEqual(len(PARSER_PATTERN.findall(test_string)), 28)

    def test_parser_three(self):
        test_string_3 = '1/8 PD10 5.4 0 3 2 1 6 5 7 PU @4f 4.4 @F @5'
        self.assertEqual(len(PARSER_PATTERN.findall(test_string_3)), 15)
    
    def test_live_looper_one(self):
        """Test the live looper function."""
        # We use a mock input via a StringIO object instead of 'raw_input',
        # which requires human intervention.    
        test_string = "1: i=7 t=60 div=17\n1: c d e f g'\ndone\n"
        fp = StringIO(test_string)
        microcsound.main.live_input_func = dummy_live_input_func(fp)
        result = live_loop_in()
        result_2 = process_buffer(result, rt_mode=True)
        self.assertIn('i200 0 -1\ni7.0 0.000 0.250  0.66  261.62557  0.5  1' \
                      '  \n' \
                      'i7.0 0.250 0.250  0.66  295.66718  0.5  1  \n' \
                      'i7.0 0.500 0.250  0.66  334.13815  0.5  1',
                      result_2[1])

    def test_pedal_string(self):
        """Test the use of pedal indications on duration"""
        test_string = "1: div=0\n1: i=1 2/1 r 1/1 PD5 0 r 1 2 3 PU\ndone\n"
        fp = StringIO(test_string)
        microcsound.main.live_input_func = dummy_live_input_func(fp)
        result = live_loop_in()
        result_2 = process_buffer(result, rt_mode=True)
        expected = ('i1.0 8.000 20.000  0.66  0.0  0.5  1  \n'
                    'i1.0 16.000 12.000  0.66  1.0  0.5  1  \n'
                    'i1.0 20.000 8.000  0.66  2.0  0.5  1  \n'
                    'i1.0 24.000 4.000  0.66  3.0  0.5  1')
        self.assertIn(expected, result_2[1])

    def test_chord_handling(self):
        """Test how chords are handled"""
        test_string = "1: div=0\n1: i=1 1/1 [0 1] 2 [3 4] 5\ndone\n"
        fp = StringIO(test_string)
        microcsound.main.live_input_func = dummy_live_input_func(fp)
        result = live_loop_in()
        result_2 = process_buffer(result, rt_mode=True)
        expected = ('i1.0 0.000 4.000  0.66  0.0  0.5  1  \n'
                    'i1.0 0.000 4.000  0.66  1.0  0.5  1  \n'
                    'i1.0 4.000 4.000  0.66  2.0  0.5  1  \n'
                    'i1.0 8.000 4.000  0.66  3.0  0.5  1  \n'
                    'i1.0 8.000 4.000  0.66  4.0  0.5  1  \n'
                    'i1.0 12.000 4.000  0.66  5.0  0.5  1')
        self.assertIn(expected, result_2[1])


if __name__ == '__main__':
    unittest.main()    
