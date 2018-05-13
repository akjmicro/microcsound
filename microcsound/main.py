# -*- coding: utf-8 -*-

# version 20170929. For a list of changes, see the CHANGES file.

from readline import *
from sys import stdin, stdout, argv
from os import system
import re
import argparse

from microcsound import constants
from microcsound.parser import parser, PARSER_PATTERN
from microcsound.state import state_obj

__all__ = ['process_buffer', 'live_loop_in',
           'sanity_tests', 'main']

# cover differences between Python2.7 and Python3 for 'raw input':

try: # Python2.7
    live_input_func = raw_input
except NameError: # Python3.*
    live_input_func = input
    

def process_buffer(inbuffer, rt_mode=False):
    """Split the whole string buffer into individual voice lines
    and feed each line to the event parser
    """
    lines = inbuffer.splitlines()
    voiceline = 1
    current_string = '%i:' % voiceline
    # The main loop where the input file is read:
    # the next line searches for the current instrument number
    # in the entire buffer, and only continues when there is
    # one found:
    while re.search(current_string, inbuffer):
        inst_line = []  # start a blank string for collection
        for line_number, line in enumerate(lines, start=1):
            text = line.rstrip() # right strip the line
            if re.match(current_string, text):
                # strip voice indicator prepending
                text1 = re.sub(r'^[0-9]{1,2}[:]', r'', text)
                # get rid of barlines
                text2 = text1.replace('|', '')
                # get rid of comments:
                text3 = re.sub(r'(.*)[#]+.*', r'\1', text2)
                inst_line.append(text3)
                # check syntax:
                errors = PARSER_PATTERN.split(''.join(inst_line))
                unspaced_errors = ''.join(errors).replace(' ', '')
                if unspaced_errors != '':
                    print('there were errors at line number %i which reads:'
                          % line_number)
                    print(line)
                    print('The errors are: %s' % unspaced_errors)
                    print('the preprocessed line is:')
                    print(inst_line)
                    if not rt_mode:
                        exit()
        # now, parse the complete voice that has been collected:
        parser(''.join(inst_line))
        # advance the voice count and search again at the top of the loop:
        voiceline += 1
        current_string = r'%i:' % voiceline

    # Here is where we finally output the gathered results of the
    # parser's work:
    return state_obj.tempostring, state_obj.outstring

# live_loop_in function here:
def live_loop_in():
    """a function which handles interactive input."""
    pinbuff = 'i200 0 -1\n'
    while True:
        phrase = live_input_func('microcsound--> ')
        if phrase.strip() == 'done':
            return pinbuff
        else:
            pinbuff += phrase + '\n'
    return pinbuff    

def main():
    """The place where the magic begins, of course!"""

    argparser = argparse.ArgumentParser(
                         epilog='This is microcsound v.20171114',
                         )
    argparser.usage = '''microcsound [-h] [--orc orc_file] [-v] 
    [-i | 
          [[-o output_wav_file | -s, --score-only | -r, --realtime]
           [-t, --stdin | input_mc_filename ]
          ]  
    ] '''
    argparser.add_argument('--orc', dest='orc_file',
                           default=constants.DEFAULT_ORC_FILE,
                           help='specify an orchestra file for csound to use, '\
                                ' which is not the default (microcsound.orc)')
    argparser.add_argument('-v', '--debug', action='store_true',
                           dest='debug_mode',
                           help='turn on debug mode')
    argparser.add_argument('-i', '--interactive', action='store_true',
                           dest='interactive',
                           help='use an interactive prompt, render audio '\
                                'in realtime as well, does not work when '\
                                'any of -o, -s, or -r are specified')
    # outputs:                            
    argparser.add_argument('-o', '--output', dest='outwav',
                           help='optional wave file output name')
    argparser.add_argument('-s', '--score-only', action='store_true',
                           dest='score_only',
                           help='only generate a score to stdout, '\
                                ' do not post-process it with csound')
    argparser.add_argument('-r', '--realtime', action='store_true', 
                           dest='realtime',
                           help='render audio in realtime')
    # inputs:
    argparser.add_argument('-t', '--stdin', action='store_true',
                           dest='text_stdin',
                           help='read text from stdin')
    argparser.add_argument('filename', nargs='?',
                           help="an input '.mc' filename or filepath")
    
    args = argparser.parse_args()

    # if they don't know what they are doing!
    if len(argv) < 2:
        argparser.print_help()
        exit(0)
          
    # wasn't argparser supposed to be helpful and do this kind of 
    # shit for us?
    if args.interactive and (args.outwav or args.realtime \
                             or args.score_only or args.text_stdin \
                             or args.filename):
        raise argparser.error('-i must not be used with any other arguments')
    if args.outwav and (args.score_only or args.realtime):
        raise argparser.error('-o must not be used -s or -r')
    if args.score_only and (args.outwav or args.realtime):
        raise argparser.error('-s must not be used -o or -r') 
    if args.realtime and (args.outwav or args.score_only):
        raise argparser.error('-r must not be used -o or -s')     
    if (args.outwav or args.score_only or args.realtime) \
            and not (args.filename or args.text_stdin):
        raise argparser.error('You need to specify an input: a filename or '\
                              'stdin (-t)')

    # okay, we've checked all possible CL parsing errors, let's
    # figure out our working parameters:
    
    # show csound parsing messages?
    if args.debug_mode:
        verbosity_string = ''
    else:
        verbosity_string = ' -O null '
    
    if args.interactive or args.realtime:
        rt_mode = True
        csound_command = (constants.RT_CSOUND_COMMAND_STUB
                          + verbosity_string
                          + ' %s/%s /tmp/microcsound.sco'
                          % (constants.ORC_DIR, args.orc_file))
    else:
        rt_mode = False
        if args.filename and not args.outwav:
            out_wav = args.filename.replace('.mc', '.wav')
        else:
            out_wav = args.outwav
        csound_command = (constants.NORMAL_CSOUND_COMMAND_STUB
                          + verbosity_string
                          + ' -o %s %s/%s /tmp/microcsound.sco'
                          % (out_wav, constants.ORC_DIR, args.orc_file))

    if args.interactive:
        rt_mode = True
        try:
            while True:
                state_obj.__init__()
                live_input = live_loop_in()
                outbuf = process_buffer(live_input,
                                        rt_mode=True)
                temp_sco_file = open('/tmp/microcsound.sco', 'w')
                temp_sco_file.write('%s\n%s' % (outbuf[0], outbuf[1]))
                temp_sco_file.close()
                system(csound_command)
        except KeyboardInterrupt:
            print('bye!')
            exit()
    else:
        if args.filename:
            the_file = open(args.filename)
            outbuf = process_buffer(the_file.read(),
                                    rt_mode=rt_mode)
            the_file.close()
        elif args.text_stdin:
            outbuf = process_buffer(stdin.read(),
                                    rt_mode=rt_mode)

        # the end result, which is either a Csound score, or audio:
        if args.score_only:
            stdout.write('%s\n%s' % (outbuf[0], outbuf[1]))
        else:
            temp_sco_file = open('/tmp/microcsound.sco', 'w')
            temp_sco_file.write('%s\n%s' % (outbuf[0], outbuf[1]))
            temp_sco_file.close()
            system(csound_command)
            
if __name__ == '__main__':
    main()
