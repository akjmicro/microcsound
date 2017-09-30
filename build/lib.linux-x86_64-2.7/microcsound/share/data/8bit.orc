sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

zakinit 6,6
ziw  1, 0   ;;; init some mixer variables
ziw  0, 1
ziw  0, 2
ziw  0, 3

;;; some function tables (known as "f-tables" in Csound speak) are set up here: 
;;;gir ftgen ifn, itime, isize, igen, iarga [, iargb ] [...]
gisine    ftgen 1, 0, 256, 10, 1
gitri     ftgen 2, 0, 256, 7, 0,  64, 1, 128, -1, 64, 0
gisaw     ftgen 3, 0, 256, 7, 0, 128, 1, 0, -1, 128, 0  
gisquare  ftgen 4, 0, 256, 7, 1, 128, 1, 0, -1, 128, -1
giquarter ftgen 5, 0, 256, 7, 1,  64, 1, 0, -1, 192, -1
gieighth  ftgen 6, 0, 256, 7, 1,  32, 1, 0, -1, 224, -1

;;; ------------now the UDOs and instruments ----------- ;;;

        opcode tieStatus,i,0   ;;; Steven Yi\'s tie opcode
itie tival
if (p3 < 0 && itie == 0) ithen
    ; this is an initial note within a group of tied notes
    itiestatus = 0
elseif (p3 < 0 && itie == 1) ithen
    ; this is a middle note within a group of tied notes
    itiestatus = 1
elseif (p3 > 0 && itie == 1) ithen
    ; this is an end note out of a group of tied notes
    itiestatus = 2
elseif (p3 > 0 && itie == 0) ithen
    ; this note is a standalone note
    itiestatus = -1
endif  
        xout    itiestatus
        endop

;;;;;;;;

	instr 1  ;;; basic waveforms for 8-bit music
idur = p3
ipch = p5
;;; putting this first b/c it affect the iamp factor:
iwav = p8
if (iwav == 1) then
   icorrection = 1
elseif (iwav == 2) then
   icorrection = 0.95
elseif (iwav == 3) then
   icorrection = 0.93
elseif (iwav == 4) then
   icorrection = 0.86
else
   icorrection = 0.84
endif
iamp = ampdb((p4 * icorrection * 60) - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  =  p7
iatt= p9
idec = p10
isus = p11
irel = p12
;;; legato stuff:

itiestatus tieStatus

tigoto skipInit
    ioldpch init ipch
    ioldamp init iamp 
skipInit:
inewpch = ipch
inewamp = iamp
kpchline  linseg  ioldpch, .01, inewpch, idur-.01, inewpch
kampline  linseg  ioldamp, .01, inewamp, idur-.01, inewamp
ioldpch = inewpch
ioldamp = inewamp

if (itiestatus == -1) then
    kenv linsegr 0, iatt, iamp, idec, isus*iamp, irel, 0
elseif (itiestatus == 0) then   
    kenv linseg 0, iatt, iamp, 0, iamp
elseif (itiestatus == 1) then
    kenv init iamp
elseif (itiestatus == 2) then
    kenv linseg iamp, idur-irel, iamp, irel, 0
endif
;; end legato stuff

aout  oscil  kenv*kampline, kpchline, iwav, -1
	zawm  aout*ipanl*imix*icorrection, 1
	zawm  aout*ipanr*imix*icorrection, 2
	endin

;;; DRUMS:

	instr 2; kick
idur = p3
ipch = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  =  p7
istartpitch = 120
;;iendpitch = 40 
iendpitch = 70
;;iampscale = 2
iampscale = 1.1
k1   expon istartpitch, idur+0.1, iendpitch 
aenv expon iamp, idur+0.1, 0.001 
a1  poscil aenv, k1, 2 
        zawm a1*ipanl*imix*iampscale, 1
        zawm a1*ipanr*imix*iampscale, 2 
	endin 

	instr 3; snare 
idur = p3
ipch = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  =  p7
iampscale = .5
idecay = 0.1
islope = 0.1
aenv   expon   iamp,  idecay,  iamp*islope 
a1     oscili  aenv, 147, 1 
arand  rand    aenv 
        zawm (a1+arand)*ipanl*imix*iampscale, 1 
        zawm (a1+arand)*ipanl*imix*iampscale, 2 
	endin 

	instr 4; hihat closed 
idur = p3
ipch = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  =  p7
idecay = 0.06
islope = 0.06
aamp   expon iamp, idecay, iamp*islope 
arand  rand  aamp 
        zawm arand*ipanl*imix, 1 
        zawm arand*ipanl*imix, 2 
	endin

	instr 5; hihat open 
idur = p3
ipch = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  =  p7
iampscale = 0.6 ;; used to be .5
islope = 0.2
idecay = 0.2
aamp   expon iamp,  idecay, iamp*islope 
arand  rand  aamp 
        zawm arand*ipanl*imix*iampscale, 1 
        zawm arand*ipanl*imix*iampscale, 2 
	endin 

	instr 10 ;-----VIRTUAL DRUMKIT-----;
idur    =  p3
iwhich	=  p5 + 2  ;;add two to get the instrument
iamp    =  p4
ipan    =  p6
imix    =  p7

event_i "i", iwhich, 0, idur, iamp, iwhich, ipan, imix

	endin

;------------------------;
;-------MIXER/REVERB-----;
;------------------------;

	instr 200
;;;; actual audio:
aleft	zar	1
aright	zar     2
ktrig   zkr 	4
if (ktrig == 1) kgoto zak_stuff
	kgoto default_stuff

default_stuff:
 kdry    =   1
 kwet	 =   0
 kroom   =   0
 kfco    =   0
 goto out_stuff

zak_stuff:
 kdry	zkr	0
 kwet	zkr	1
 kroom	zkr	2
 kfco	zkr	3
 goto out_stuff

out_stuff:
	;;denorm aleft, aright
alv, arv reverbsc aleft, aright, kroom, kfco, sr, 0.7, 1
alpost = (aleft*kdry + alv*kwet)
arpost = (aright*kdry + arv*kwet)
iqvar = 1.414
ivol1 = ampdb(-2)
ivol2 = ampdb(-2)
ivol3 = ampdb(0)
ivol4 = ampdb(-2) 
ivol5 = ampdb(-2)
ivol6 = ampdb(-2)
ivol7 = ampdb(0)
ivol8 = ampdb(1)
ivol9 = ampdb(3)
ivol10 = ampdb(4)
;; left channel EQ
ale1 butterbp alpost, 31, 31/iqvar
alo1 = ale1 * ivol1
ale2 butterbp alpost, 63, 63/iqvar
alo2 = ale2 * ivol2
ale3 butterbp alpost, 125, 125/iqvar
alo3 = ale3 * ivol3
ale4 butterbp alpost, 250, 250/iqvar
alo4 = ale4 * ivol4
ale5 butterbp alpost, 500, 500/iqvar
alo5 = ale5 * ivol5
ale6 butterbp alpost, 1000, 1000/iqvar
alo6 = ale6 * ivol6
ale7 butterbp alpost, 2000, 2000/iqvar
alo7 = ale7 * ivol7
ale8 butterbp alpost, 4000, 4000/iqvar
alo8 = ale8 * ivol8
ale9 butterbp alpost, 8000, 8000/iqvar
alo9 = ale9 * ivol9
ale10 butterbp alpost, 16000, 16000/iqvar
alo10 = ale10 * ivol10
;; right channel EQ
are1 butterbp arpost, 31, 31/iqvar
aro1 = are1 * ivol1
are2 butterbp arpost, 63, 63/iqvar
aro2 = are2 * ivol2
are3 butterbp arpost, 125, 125/iqvar
aro3 = are3 * ivol3
are4 butterbp arpost, 250, 250/iqvar
aro4 = are4 * ivol4
are5 butterbp arpost, 500, 500/iqvar
aro5 = are5 * ivol5
are6 butterbp arpost, 1000, 1000/iqvar
aro6 = are6 * ivol6
are7 butterbp arpost, 2000, 2000/iqvar
aro7 = are7 * ivol7
are8 butterbp arpost, 4000, 4000/iqvar
aro8 = are8 * ivol8
are9 butterbp arpost, 8000, 8000/iqvar
aro9 = are9 * ivol9
are10 butterbp arpost, 16000, 16000/iqvar
aro10 = are10 * ivol10
;; send to output
        outs (alo1+alo2+alo3+alo4+alo5+alo6+alo7+alo8+alo9+alo10)*0.8, (aro1+aro2+aro3+aro4+aro5+aro6+aro7+aro8+aro9+aro10)*0.8
	zacl 1,2
	endin

	instr 201 ;;; turns on the mixer for indefinite period
event_i "i", 200, 0 , -1
	endin

	instr 202 ;;; master mixer controls
ktrig = p5  ;;;; p5 is a dummy trigger field, use '1' to activate controls
kdry = p8   ;;;; dry volume
kwet = p9   ;;;; wet volume
kroom = p10  ;;; room size
kfco = p11  ;;;; room freq damp
zkw kdry, 0
zkw kwet, 1
zkw kroom, 2
zkw kfco, 3
zkw ktrig, 4
	endin
