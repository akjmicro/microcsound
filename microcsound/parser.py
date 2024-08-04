# -*- coding: utf-8 -*-

import re
from random import gauss

from microcsound import config, handlers
from microcsound.state import state_obj

PARSER_PATTERN = re.compile(
    r"(?:(?:mix|pan|div|gr|gv|gs|t|i)[=](?:[0-9]{0,5}[.]?[0-9]{1,5}|\"<\"))"
    r"|(?:(?:p[89]{1}|p[1-9][0-9])[=](?:[-0-9.<]+))"
    r"|(?:key[=][0-9]+[:][0-9]+)"
    r"|(?:\"[-0-9.<%]+\")"
    r"|(?:[&][\-+]?[0-9]*)"
    r"|(?:[`])"
    r"|(?:\[L:[0-9]{1,4}[/][0-9]{1,4}\])"
    r"|(?:[0-9]{1,4}[/][0-9]{1,4})"
    r"|[rzx][0-9]{0,2}"
    r"|[@](?:[0-9]?[.][0-9]{1,3}|[0-9A-Fa-f]{1,2}|[<])"
    r"|PD[0-9]{1,3}"
    r"|PU"
    r"|(?:(?:[.\(])?(?:\^/2|_/2|[_^=/\\<>!?]|\xc2\xa1|\xc2\xbf)*[a-g](?:\*)*[,']*[0-9]{0,2}[-]?[)]?)"
    r"|(?:(?:[.\(])?(?:[0-9]+[:][0-9]+)\)?(?:[| t](?![=]))*)"
    r"|(?:(?:[.\(])?(?:[0-9]+[.])?(?:[-]?[0-9]+)\)?(?:[| t](?![=]))*)"
    r"|\["
    r"|\]"
)


def parser(inst_line):
    """This is the logical heart of the application."""
    # before parsing this voice, set up the starting points:

    # reset SOME of the state variables:
    state_obj.reset_voice()

    for event in PARSER_PATTERN.findall(inst_line):
        # a non-event?
        if event == "":
            continue

        # a variable assignment:
        elif re.match(
            r"(?P<type>div|mix|pan|gr|gv|gs|t|i)[=]"
            r"(?P<value>(?:[0-9]{1,5}[.]?[0-9]{0,5}|\"<\"))",
            event,
        ):
            handlers.handle_global_variable_event(event)
            continue

        # an instrument parameter is set:
        elif re.match(r"(?:(?:p[89]{1}|p[1-9][0-9])[=](?:[-0-9.<]+))", event):
            handlers.handle_instrument_parameter(event)
            continue

        # instrument parameters are set all at once:
        elif re.match(r"(?:\"[-0-9.<%]+\")", event):
            handlers.handle_many_instrument_parameters(event)
            continue

        # transposition by JI ratio:
        elif "key" in event:
            handlers.handle_JI_transpose(event)
            continue

        # lengths:
        elif re.match(r"(?:\[L:)?[0-9]{1,4}[/][0-9]{1,4}(?:\])?", event):
            handlers.handle_length(event)
            continue

        # rests:
        elif event[0] == "r" or event[0] == "z" or event[0] == "x":
            handlers.handle_rest(event)
            continue

        # chords are enabled by 'stopping the clock':
        elif event in "[]":
            handlers.handle_chord_status(event)
            continue

        # added this for sustain pedal passages:
        elif event.startswith("PD") or event.startswith("PU"):
            handlers.handle_pedal(event)
            continue

        # grid time pointer can be changed for 'time travel' :-) :
        elif event[0] == "&":
            handlers.handle_time_travel(event)
            continue

        # report on current time for given voice:
        elif "`" in event:
            handlers.handle_time_report(event)
            continue

        # attack level:
        elif event[0] == "@":
            handlers.handle_attack(event)
            continue

        ####################
        ## pitch events : ##
        ####################

        # ratio notation (JI):
        elif re.match(r"(?:[.\(])?(?:[0-9]+[:][0-9]+)", event):
            handlers.handle_JI_notation(event)

        # [oct.]degree notation:
        elif re.match(r"(?:[.\(])?(?:[0-9]+[.])?(?:[-]?[0-9]+)", event):
            handlers.handle_numeric_notation(event)

        # symbolic diatonic notation:
        else:
            handlers.handle_symbolic_notation(event)

        # possibly we have a JI transposition:
        pitch = float(state_obj.pitch) * float(state_obj.key)

        # OK, if we have finally gotten a pitch event, we know what's what
        # now. If we've gotten this far in the loop,
        # we can calculate stuff....
        on_time = state_obj.grid_time + (
            gauss(0, 0.001) * state_obj.gaussian_rhythm * state_obj.tempo * 0.01666
        )
        if on_time < 0:
            on_time = 0
        if state_obj.default_attack != "<":
            attack = state_obj.default_attack + int(gauss(0, state_obj.gaussian_volume))
            if attack >= 1:
                attack = 1
        else:
            attack = state_obj.default_attack

        # this next block take into account whether the note is a tie or a
        # regular note event, and takes appropriate actions:
        if state_obj.tie:
            # if note is not in the list of tied notes, add it.
            if pitch not in state_obj.tie_dict[state_obj.instr]:
                state_obj.tie_dict[state_obj.instr][pitch] = [
                    on_time,
                    state_obj.length_factor,
                    attack,
                    state_obj.pan,
                ]
            # if it IS there already, add duration to it.
            else:
                state_obj.tie_dict[state_obj.instr][pitch][1] += state_obj.length_factor
            continue
        # or if the note was a tie, and is now not tied, that means
        # it's time actually get its endpoints and send it to the
        # output list:
        if pitch in state_obj.tie_dict[state_obj.instr]:
            tie_info = state_obj.tie_dict[state_obj.instr].pop(pitch)
            on_time = tie_info[0]
            state_obj.length_factor = tie_info[1] + state_obj.length_factor
            attack = tie_info[2]
            state_obj.pan = tie_info[3]
        # calculate duration:
        if state_obj.pedal_down:
            duration = state_obj.arrival - on_time
        else:
            if state_obj.articulation == "staccato":
                duration = ((state_obj.tempo / 60.0) * state_obj.staccato_length) + (
                    gauss(0, 0.001)
                    * state_obj.gaussian_staccato
                    * state_obj.tempo
                    * 0.01666
                )
            elif state_obj.articulation == "legato":
                # negative p3 for legato instruments
                duration = (state_obj.length * state_obj.length_factor) * -1
            else:
                duration = state_obj.length * state_obj.length_factor

        # finally, a place to put the output text:
        state_obj.outstring = (
            state_obj.outstring
            + "i%1.1f %1.3f %1.3f  %s  %s  %s  %s  %s\n"
            % (
                state_obj.instr,
                on_time,
                duration,
                attack,
                pitch,
                state_obj.pan,
                state_obj.mix,
                " ".join(state_obj.xtra).replace('"', ""),
            )
        )

        # update grid_time for next event, but only if not in chord status
        # '[]' mode:
        if not state_obj.chord_status:
            state_obj.grid_time += state_obj.length * state_obj.length_factor
