# -*- coding: utf-8 -*-

import re

from microcsound import config, helpers
from microcsound.state import state_obj


def handle_global_variable_event(event):
    """Handle global event changes.

    Heavy on side-effects.
    """
    global_variable = event.split("=")
    evtype, val = global_variable[0], global_variable[1]
    if evtype == "t":
        state_obj.tempo = float(val)
        if state_obj.grid_time == 0:
            state_obj.tempostring = "t %s %s " % (state_obj.grid_time, val)
        else:
            state_obj.tempostring = "%s%s %s " % (
                state_obj.tempostring,
                state_obj.grid_time,
                val,
            )
    elif evtype == "div" or evtype == "edo":
        state_obj.div = float(val)
    elif evtype == "i":
        state_obj.instr = float(val)
        state_obj.tie_dict[state_obj.instr] = {}
    elif evtype == "pan":
        if val == "<":
            val = "<"
        state_obj.pan = val
    elif evtype == "gr":
        state_obj.gaussian_rhythm = float(val)
    elif evtype == "gv":
        state_obj.gaussian_volume = float(val)
    elif evtype == "gs":
        state_obj.gaussian_staccato = float(val)
    elif evtype == "nls":
        state_obj.non_legato_space = float(val)
    else:
        if val == "<":
            val = "<"
        state_obj.mix = val


def handle_instrument_parameter(event):
    """Handle an instrument parameter event."""
    xtext = event.split("=")
    pslot = int(xtext[0].replace("p", "")) - 8
    try:
        state_obj.xtra[pslot] = xtext[1]
    except:
        print(
            "Instrument parameters must be declared as a string "
            "before they can be altered! Problem statement is: %s" % event
        )
        exit()


def handle_many_instrument_parameters(event):
    """Handle a group parameter event for an instrument."""
    state_obj.xtra = event.split("%")


def handle_JI_transpose(event):
    """Handle a JI transposition event."""
    key_ratio_text = event.split("=")[1]
    key_ratio_text_new = key_ratio_text.split(":")
    state_obj.key = float(key_ratio_text_new[0]) / float(key_ratio_text_new[1])


def handle_length(event):
    """Handle a change in note length."""
    z = re.search(r"(?:\[L:)?([0-9]{1,4})[/]([0-9]{1,4})(?:\])?", event)
    numerator = float(z.group(1))
    denominator = float(z.group(2))
    state_obj.length = (numerator / denominator) * 4


def handle_rest(event):
    """Handle a rest event."""
    factor = event[1:]
    if factor != "":
        state_obj.length_factor = int(factor)
    else:
        state_obj.length_factor = 1
    state_obj.grid_time += state_obj.length * state_obj.length_factor


def handle_chord_status(event):
    """Handle a chord status change event."""
    if event == "[":
        state_obj.chord_status = 1
    else:
        state_obj.chord_status = 0
        state_obj.grid_time += state_obj.length * state_obj.length_factor


def handle_pedal(event):
    """Handle a pedalling event."""

    if "PD" in event:
        state_obj.pedal_down = True
        ev = re.match(r"PD(?P<arrival>\d{1,3})", event)
        state_obj.arrival = (
            int(ev.group("arrival")) * state_obj.length
        ) + state_obj.grid_time
    else:
        state_obj.pedal_down = False


def handle_time_travel(event):
    """Handle a time travel event."""
    r = re.search(r"[&]([\-+]?)([0-9]*)", event)
    sign = r.group(1)
    value = r.group(2)
    if sign and sign == "-":
        state_obj.grid_time -= state_obj.length * int(value)
    elif sign and sign == "+":
        state_obj.grid_time += state_obj.length * int(value)
    else:
        state_obj.grid_time = state_obj.length * int(value)


def _handle_time_report_helper(grid_time):
    """Help report the grid time.

    This seems silly, but makes asserting what was called easier in
    a unit-testing context.
    """
    print("Grid time is currently %f" % grid_time)


def handle_time_report(event):
    """Handle a time reporting event."""
    _handle_time_report_helper(state_obj.grid_time)


def handle_attack(event):
    if "." in event[1:] or event[1] == "-":
        state_obj.default_attack = float(event[1:])
    elif "<" in event[1:]:
        state_obj.default_attack = "<"
    else:
        if len(event[1:]) == 2:
            state_obj.default_attack = eval("%s/99." % event[1:])
        elif len(event[1:]) == 1:
            state_obj.default_attack = eval("%s0/99." % event[1:])


def handle_symbolic_notation(event):
    """Handle a symbolic note event."""
    mylist = re.search(
        r"(?P<articul>[.\(]?)"
        r"(?P<pitch>(?:\^/2|_/2|[_^=/\\<>!?]|"
        r"\xc2\xa1|\xc2\xbf)*"
        r"[a-g](?:\*)*[',]*)"
        r"(?P<len>[0-9]{0,2})(?P<tie>[-]?)"
        r"(?P<legato_end>[)]?)",
        event,
    )
    articul = mylist.group("articul")
    pitch = mylist.group("pitch")
    length_factor = mylist.group("len")
    tie_dash = mylist.group("tie")
    legato_end = mylist.group("legato_end")

    if articul and articul == "(":
        state_obj.articulation = "legato"
    elif articul and articul == ".":
        state_obj.articulation = "staccato"
    elif legato_end:
        state_obj.articulation = "non-legato"

    articulation = state_obj.articulation

    if pitch:
        degree = helpers.solfege2et(pitch, state_obj.div)
        state_obj.pitch = helpers.degree2hz(degree, state_obj.div)
    if length_factor:
        state_obj.length_factor = int(length_factor)
    else:
        state_obj.length_factor = 1

    if tie_dash:
        state_obj.tie = 1
    else:
        state_obj.tie = 0


def handle_numeric_notation(event):
    """Handle and return data from a numeric notation event."""
    mylist = re.search(
        r"(?P<articul>[.\(]?)"
        r"(?:(?P<oct>[0-9]+)[.])?"
        r"(?P<deg>[-]?[0-9]+)"
        r"(?P<legato_end>[\)]?)"
        r"(?P<tie>[| t]*)",
        event,
    )
    articul = mylist.group("articul")
    try:
        myoct = mylist.group("oct")
    except:
        print(event)
    deg = mylist.group("deg")
    legato_end = mylist.group("legato_end")
    tie_phrase = mylist.group("tie")

    if articul and articul == "(":
        state_obj.articulation = "legato"
    elif articul and articul == ".":
        state_obj.articulation = "staccato"
    elif legato_end:
        state_obj.articulation = "non-legato"

    if myoct:
        state_obj.octave = int(myoct)
    if deg:
        degree_raw = int(deg)
        if state_obj.div > 0:
            degree = (
                state_obj.octave - config.MIDDLE_C_OCTAVE
            ) * state_obj.div + degree_raw
            state_obj.pitch = helpers.degree2hz(degree, state_obj.div)
        else:
            # when div=0, pitch is uninterpreted
            state_obj.pitch = degree_raw

    length_factor = 1
    if tie_phrase:
        length_factor += tie_phrase.count("t")

    # we've already handled the ties ourselves:
    state_obj.tie = 0
    state_obj.length_factor = length_factor


def handle_JI_notation(event):
    """Handle and return data from a JI note event."""
    mylist = re.search(
        r"(?P<articul>[.\(]?)"
        r"(?P<ratio>[0-9]+[:][0-9]+)"
        r"(?P<legato_end>[\)]?)"
        r"(?P<tie>[| t]*)",
        event,
    )
    articul = mylist.group("articul")
    try:
        ratio_text = mylist.group("ratio")
    except:
        print("Malformed or absent ratio: %s" % event)
    legato_end = mylist.group("legato_end")
    tie_phrase = mylist.group("tie")

    if articul and articul == "(":
        state_obj.articulation = "legato"
    elif articul and articul == ".":
        state_obj.articulation = "staccato"
    elif legato_end:
        state_obj.articulation = "non-legato"

    ratio_text_new = ratio_text.split(":")
    ratio = float(ratio_text_new[0]) / float(ratio_text_new[1])
    state_obj.pitch = config.MIDDLE_C_HZ * ratio

    length_factor = 1
    if tie_phrase:
        length_factor += tie_phrase.count("t")

    # we've already handled the tie:
    state_obj.tie = 0
    state_obj.length_factor = length_factor
