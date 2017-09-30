# -*- coding: utf-8 -*-

from microcsound import constants

class State(object):
    ## storing some state in a safe object interface.
    ## these are the variables that would be annoying to have to redefine
    ## for every voice line...
    def __init__(self):
        self.div = 31
        self.instr = 1
        self.tempo = 120
        self.tempostring = 't 0 120 ' ###
        self.outstring = 'i200 0 -1\n' ### everything output goes here
                            ### added starting zak mixer statement on
                            ### 2010-08-03
                            ### instead of an empty starting string
        self.reset_voice()
    
    def reset_voice(self):
        self.length = 1/4.
        self.octave = 5
        self.articulation = 'non-legato'
        ## basic variables
        self.grid_time = 0
        self.chord_status = 0
        self.xtra = ['']
        ## pitch related defaults:
        self.octave = constants.MIDDLE_C_OCTAVE
        self.degree = 0
        self.key = 1
        ## rhythm:
        self.length_factor = 1
        self.tie_dict = {}
        self.tie = 0
        ## articulation
        self.staccato_length = .2
        self.non_legato_space = .02
        ## pedalling  
        self.pedal_down = False
        self.arrival = 0
        ## other defaults: 
        self.default_attack = .66
        self.pan = 0.5
        self.mix = 1
        self.gaussian_rhythm = 0
        self.gaussian_volume = 0 ### gaussian volume variance
        self.gaussian_staccato = 0 ### gaussian staccato variance

# we instatiate a singleton:
state_obj = State()
