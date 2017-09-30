This file includes a general description of 'microcsound' usage, and
installation instructions. Please read further about microcsound in
the 'microcsound_tutorial.html' file (via a browser). An example file,
'ciconia.mc', can be studied to get the hang of how it is used in
practice.

Microcsound is a feature extension and 'migration' away from MIDI of a
previous Python script titled 'micro_composer', which was itself
formerly called 'et_compose'.

Microcsound implements the following features:

* an intuitive, clean shorthand syntax that allows one to both easily write
CSound scores (and, with perhaps some degree of copy/modification, use
the same file to use as an input to 'abcm2ps' to produce postscript-output 
traditional 'written' scores.)

* a focus on flexible entry of microtonal music, the emphasis being on
enabling one to compose in various equal-temperaments and just
intonation.

* symbols for various microtonal commas, so that extended just
intonation harmony is easily accessible in a convenient intuitive way.

improvements from et_compose and micro_composer:
_______________________________________________

* implementation of chord notation using brackets

* implementation of a 'time pointer' notation which allows arbitrary
number of counterpoint layers in a single 'voice'

See the example 'mary.mc' and the tutorial.txt file for an understanding of
how to use the syntax for your own compositions.

TO INSTALL:
____________

You must have Python and Csound installed, and Csound must be set up with
all of its prerequisites, and its environment variables should be set up
and working, too. See Csound documentation for help.

On Linux (*nix or MacOS-X with Unix functionality), open and read the
included 'install.py' file, make sure the target locations are in line with
your system's setup, and then simply run the 'install.py'
script like so, from a commandline terminal prompt:

Either as root (superuser):

    $ ./install.py

or temporarily assume root's identity, to do it as a 'sudo' command....

    $ sudo ./install.py

This will copy the needed libraries to your Python directory, and copy the
executable 'microcsound' script to /usr/local/bin by default.

If the install script fails, check that Python is installed, and that the
path at the top of the python2 script reflects the location of your Python
executable (it defaults to /usr/bin/python2)

You may also want to edit the variables at the top of the 'microcsound'
script itself, especially the first 'orc_dir' variable. Open it with an editor, and change the four variables towards
the top, in the block that look like this:

##### EDIT DEFAULTS HERE:           
##### orchestra dir, where the script can look for your 
##### Csound orchestra files:
orc_dir = '/home/YOUR_LOGIN_NAME/csound_files/'
##### the name, without a full path, of the default Csound orchestra
##### file microcsound will look for if none is explicitly stated
default_orc_file = 'microcsound.orc'
##### the beginning stub of a Csound command for non-realtime use:
normal_csound_command_stub = 'csound -d -m0 -W'
##### The beginning stub Csound command for realtime use:
rt_csound_command_stub = 'csound -d -m0 -+rtaudio=alsa -b4096 -B4096 -odac'
##### END USER EDITING 

Change these variables to ones that make sense on your system.
Just edit between the single quotes to customize. Make sure the single
quotes remain intact when you're done!

To use the program:
___________________

It's best to start by seeing all the command-line options, so first, try:

         $ microcsound -h

After writing a little example in a file you might name 'yourfile.mc', try
this:  

         $ microcsound yourfile.mc

the script outputs a wave file to the current directory, by default the wave
is called 'microcsound_out.wav', but you can change this using the '-o' 
command line switch. If you use the '-s', it will avoid the 
final step of compiling the orc/score pair and just put a csound score to 
standard out. To put this output into a file, use redirection like so:

         $ microcsound -s yourfile.mc > yourcsoundscore.sco

You could also use an editor like 'joe' or 'emacs' that allows the
capture of the text output of a process, and call the script from
within the editing session of a .csd (orc+sco) file; in this way one
can be between the <CsScore> and </CsScore> tags and fill the space
with the script output.

For realtime experimentation, just call the script with the name of a
csound '.orc' file, you can edit the variables at the top of the script
so that it automatically looks for orchestra files in a default directory.

For instance:

	$ microcsound -i --orc fat_moog.orc

will give you a prompt, and you can type in a Microcsound 'score', and when
you want it rendered, hit return and type 'done' and then hit return again.
In this example above, it will search in the directory I provided in the
script for the 'fat_moog.orc' file.	

See the csound documentation for how to use all the options and
command line switches to get the final audio output from csound.
The csound command called by the script can be changed at the top 
of the script in the "user variables" area.

Enjoy!

Aaron Krister Johnson

Please report bugs and successes to aaron@untwelve.org
