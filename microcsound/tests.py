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
from microcsound.helpers import octaves, solfege2et, degree2hz

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
        """ test the regex pattern detection."""
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

    def test_parser_four(self):
        test_string_4 = '1/8 cdef2g`abcc,c,,2'
        self.assertEqual(len(PARSER_PATTERN.findall(test_string_4)), 12)

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

    def test_live_looper_two(self):
        """Test the live looper function for time reporting."""
        # We use a mock input via a StringIO object instead of 'raw_input',
        # which requires human intervention.
        test_string = ("1: i=7 t=60 div=17\n"
                       "1: 1/8 c d 1/16 e f g' ` a, b, c c' c,\ndone\n")
        fp = StringIO(test_string)
        microcsound.main.live_input_func = dummy_live_input_func(fp)
        result = live_loop_in()
        result_2 = process_buffer(result, rt_mode=True)
        assert False

    def test_pedal_string(self):
        """Test the use of pedal indications on duration."""
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
        """Test how chords are handled."""
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


class HelperTests(MicrocsoundTests):
    def test_octaves(self):
        """tests the simple octaves function."""
        expected = '0.5849625'
        # we convert to string to avoid floating-point equality testing
        # issues:
        result = str(octaves(1.5))
        self.assertTrue(result.startswith(expected))

    def test_solfege2et_middle_c_same(self):
        """middle c same in any division."""
        self.assertTrue(solfege2et("c", 17) == solfege2et("c", 19))

    def test_solfege2et_double_division(self):
        """octave relation by doubling division."""
        self.assertTrue(solfege2et("d", 34) == solfege2et("d", 17) * 2)

    def test_solfege2et_Csharp_Dflat_superpyth(self):
        """certain tunings (e.g. 17edo) have the property that C# is HIGHER
        than Db; check that here."""
        self.assertTrue(solfege2et("^c", 17) > solfege2et("_d", 17))

    def test_solfege2et_Csharp_Dflat_meantone(self):
        """Tests the normal meantone case where C# LOWER than Db."""
        self.assertTrue(solfege2et("^c", 19) < solfege2et("_d", 19))

    def test_solfege2et_octave_up(self):
        """Tests that octave relationships work."""
        for div in range(5, 53):
            self.assertTrue(solfege2et("g'", div) ==
                            solfege2et("g", div) + div)

    def test_solfege2et_octave_down(self):
        """Tests that octave relationships work."""
        for div in range(5, 53):
            self.assertTrue(solfege2et("g,", div) ==
                            solfege2et("g", div) - div)

    def test_solfege2et_f_to_g_same_c_to_d(self):
        """Tests that step relationships work."""
        for div in range(5, 53):
            self.assertTrue(solfege2et("g", div) - solfege2et("f", div)
                         == solfege2et("d", div) - solfege2et("c", div))

    def test_solfege2et_31edo_7_4_ratio(self):
        """Test the 7/4 ratio in 31edo is the right value."""
        self.assertTrue(solfege2et("^a", 31) == 25)

    def test_solfege2et_53edo_11_8_ratio(self):
        """Test the 11/8 ratio in 53edo is the right value."""
        self.assertTrue(solfege2et("!f", 53) == 24)

    def test_degree2hz_in_10edo(self):
        """Test our degree2hz function."""
        self.assertTrue(degree2hz(3, 10).startswith('322.0988'))

    def test_solfege2et_22edo_11_8_ratio_multiple_accidentals(self):
        """Test !_b is an 11/8 from f in 22edo."""
        self.assertTrue(solfege2et("!_b", 22) == 19)
        self.assertTrue(solfege2et("_b", 22) == 18)


if __name__ == '__main__':
    unittest.main()
