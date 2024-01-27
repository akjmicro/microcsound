## microcsound

### TO INSTALL:
____________

* Make sure you have Python and Csound installed

* Choose as install method, *pip* or *git* (pip is recommended if you have it)

**From pip:**
```
    pip install microcsound
```
__________________________________

**From git:**

Either download from the 'dist' directory here, or:
```
    git clone https://github.com/akjmicro/microcsound
```
Once downloaded, in the 'microcsound' directory:
```
    python -m pip install .
```
___________________________________

* Files will be installed into a Python lib directory on your system. E.G.,
on a Linux system, something like _/usr/local/lib/Python3.6_

* You may also want to edit the variables at the top of the 'constants.py'
script itself, especially the first 'orc_dir' variable. Open it with an editor, and change the four variables towards
the top, in the block that look like this:

```python
##### EDIT DEFAULTS HERE:           
##### orchestra dir, where the script can look for your 
##### Csound orchestra files:
orc_dir = '/home/YOUR_LOGIN_NAME/csound_files/'
##### the name, without a full path, of the default Csound orchestra
##### file microcsound will look for if none is explicitly stated
default_orc_file = 'microcsound_basic.orc'
##### the beginning stub of a Csound command for non-realtime use:
normal_csound_command_stub = 'csound -d -m0 -W'
##### The beginning stub Csound command for realtime use:
rt_csound_command_stub = 'csound -d -m0 -+rtaudio=alsa -b4096 -B4096 -odac'
##### END USER EDITING 
```

Change these variables to ones that make sense on your system.
Just edit between the single quotes to customize. Make sure the single
quotes remain intact when you're done!

### ABOUT:

Microcsound implements the following features:

* an intuitive, clean shorthand syntax that allows one to both easily write
CSound scores

* a focus on flexible entry of microtonal music, the emphasis being on
enabling one to compose in various equal-temperaments and just
intonation.

* symbols for various microtonal commas, so that extended just
intonation harmony is easily accessible in a convenient intuitive way.

* implementation of chord notation using brackets

* implementation of a 'time pointer' notation which allows arbitrary
number of counterpoint layers in a single 'voice'

See the example 'ciconia.mc' (a rendering of a medieval piece) 
and the tutorials/docs for an understanding of how to use the syntax 
for your own compositions.

## To use:

It's best to start by seeing all the command-line options, so first, try:
```
         $ microcsound -h
```

After writing a little example in a file you might name 'yourfile.mc', try
this:  
```
         $ microcsound yourfile.mc
```

The script outputs a wave file to the current directory, by default the wave
is called 'microcsound_out.wav', but you can change this using the '-o' 
command line switch. If you use the '-s', it will avoid the 
final step of compiling the orc/score pair and just put a csound score to 
standard out. To put this output into a file, use redirection like so:
```
         $ microcsound -s yourfile.mc > yourcsoundscore.sco
```

You could also use an editor like 'joe' or 'emacs' that allows the
capture of the text output of a process, and call the script from
within the editing session of a .csd (orc+sco) file; in this way one
can be between the <CsScore> and </CsScore> tags and fill the space
with the script output.

For realtime experimentation, just call the script with the name of a
csound '.orc' file, you can edit the variables at the top of the script
so that it automatically looks for orchestra files in a default directory.

For instance:
```
	$ microcsound -i --orc fat_moog.orc
```

will give you a prompt, and you can type in a microcsound 'score', and when
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
