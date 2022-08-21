# -*- coding: utf-8 -*-

# EDIT DEFAULTS HERE:
# orchestra dir, where the script can look for your
# Csound orchestra files:
ORC_DIR = "/usr/local/share/microcsound"
# the name, without a full path, of the default Csound orchestra
# file that microcsound will look for if none is explicitly stated
DEFAULT_ORC_FILE = "microcsound_basic.orc"
# the beginning stub of a Csound command for non-realtime use:
NORMAL_CSOUND_COMMAND_STUB = "/usr/bin/csound -d --messagelevel=0 --nodisplays -W"
# The beginning stub Csound command for realtime use:
RT_CSOUND_COMMAND_STUB = "/usr/bin/csound -b2048 -B2048 -odac"
# END USER EDITING

MIDDLE_C_HZ = 261.6255653
# for changing middle c numerical pitch standard in the notation
# (MIDI=5, CSound=8, piano=4) MIDI is default:
MIDDLE_C_OCTAVE = 5
