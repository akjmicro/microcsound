sr = 44100
ksmps = 1
nchnls = 2
0dbfs = 1

zakinit 6,6
ziw  1, 0   ;;; init some mixer variables
ziw  0, 1
ziw  0, 2
ziw  0, 3
;;; some function tables (known as "f-tables" in Csound speak) are set up here: 
gisine 	ftgen 0, 0, 65536, 10, 1 ;;; sine wave
giflute ftgen 0, 0, 65536, 10, 1, 0.006, 0.05, 0.006, 0.003 ;;flute wave
gitri 	ftgen 0, 0, 8192, -7, -1, 4096, 1, 4096, -1 ;;triangle wave
gisnare ftgen 0, 0, 512, 9, 10, 1, 0, 16, 1.5, 0, 22, 2, 0, 23, 1.5,  0 ;; for Joaquin\'s snare
gismallsine ftgen 0, 0, 4096, 10, 1 ;;; for 'fof', which is comp-intensive
gisigmoid ftgen 0, 0, 1024, 19, 0.5, 0.5, 270, 0.5
gioneshot1 ftgen 0, 0, 513, 5, 256, 512, 1 ;;; exponential decay table
gioneshot2 ftgen 0, 0, 513, 5, 4096, 512, 1 ;;; another exponential decay table
giorgan    ftgen 0, 0, 8192, 10, 1, 0.5, 0.2, 0.33, 0, 0.1, 0, 0.1 ;; organ waveform 
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

opcode AllPass, a, a
	ain xin
	; Generate stable poles
	irad exprand 0.1
	irad = 0.99 - irad
	irad limit irad, 0, 0.99
	;iang random -$M_PI, $M_PI
	iang random -$M_PI, $M_PI
	ireal = irad * cos(iang)
	iimag = irad * sin(iang)
	print irad, iang, ireal, iimag
	
	; Generate coefficients from poles
	ia2 = (ireal * ireal) + (iimag * iimag)
	ia1 = -2*ireal
	ia0 = 1
 
	ib0 = ia2
	ib1 = ia1
	ib2 = ia0
 
	printf_i "ia0 = %.8f ia1 = %.8f ia2= %.8f\n", 1, ia0, ia1, ia2
	aout biquad ain, ib0, ib1, ib2, ia0, ia1, ia2
	
	xout aout
endop

;;;;;;;;

	instr 1  ;; fat moog
icps = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  =  p7
iatt = p8  ;;originally .01
idec = p9 ;;originally 7
isus = iamp*p10 ;; originally 0, or non-existent!
irel = p11 ;;originally .7
ifltcoffmin = p12
ifltcoffmax = p13
ifltamp = iamp*(ifltcoffmax-ifltcoffmin) + ifltcoffmin  ;;;used to be p4*4000 + 7000
ifltrez = p14
ifltatt = p15
ifltdec = p16 ;;;originally 3.8
ifltsus = ifltamp*p17
ifltrel = p18
;;; jspline variables:
ijswidth = icps * 0.01
ijslmin = .4
ijslmax = 5
ijsrmin = .3
ijsrmax = 5.2
;;; envelopes
kenv expsegr  0.001, iatt, iamp, idec, isus + 0.001, irel, 0.001
kfenv expsegr 0.001, iatt, ifltamp, ifltdec, ifltsus + 10, irel, 10
;;; fatten w/pulse width modulation
kpw	oscili	.3, 3.2, gisine  ;; pw (triangle /ramp) modulation -- try .4,.2,1
;; kres jspline kamp, kcpsMin, kcpsMax
kflmodl jspline ijswidth, ijslmin, ijslmax   ;; for the stereo flangers
kflmodr jspline ijswidth, ijsrmin, ijsrmax ;; for the stereo flangers
;; ares vco2 kamp, kcps [, imode] [, kpw] [, kphs] [, inyx]
aoscl	vco2  kenv,icps+kflmodl,0,kpw+.5,0, .333
aoscr	vco2  kenv,icps+(icps*.005)+kflmodr,0,kpw+.5,0,.333
afltl	moogvcf2 aoscl,kfenv, ifltrez
afltr	moogvcf2 aoscr,kfenv, ifltrez
afltr   delay afltr, 0.0069
	zawm afltl*ipanl*imix, 1
	zawm afltr*ipanr*imix, 2
	endin

	instr 2  ;;; accmi flute (fixed for legato after Steven Yi)
idur  = p3
iamp  = ampdb(p4 * 60 - 60)
ipch  = p5
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  = p7
irise = 0.02
irel  = 0.02
ivibwidth = p8
ivibspeed = p9
iporttime = p10

itiestatus tieStatus
iskip   tival

tigoto skipInit
    ioldpch init ipch
    ioldamp init iamp 
skipInit:
inewpch = ipch
inewamp = iamp
kpchline  linseg  ioldpch, iporttime, inewpch, idur-iporttime, inewpch
kampline  linseg  ioldamp, iporttime, inewamp, idur-iporttime, inewamp
ioldpch = inewpch
ioldamp = inewamp
if (itiestatus == -1) then
    kenv linsegr 0, irise, 1, irel, 0
elseif (itiestatus == 0) then   
    kenv linseg 0, irise, 1, 0, 1
elseif (itiestatus == 1) then
    kenv init 1
elseif (itiestatus == 2) then
    kenv linseg 1, idur-irel, 1, irel, 0
endif
;;;
knoi	gauss iamp*0.006 ;; originally 0.003
kvib    oscil   ivibwidth, ivibspeed, gisine, -1
a1	oscil    kampline+knoi, kpchline+knoi+kvib, giflute, -1
	zawm a1*kenv*ipanl*imix, 1
	zawm a1*kenv*ipanr*imix, 2
	endin

;------------------CHIPTUNE----------------;
	instr 3

idur   = abs(p3)
ipch   = p5
iamp   = ampdb(p4 * 60 - 60)
ipanr  = sqrt(p6)
ipanl  = sqrt(1-p6)
imix  =  p7
irise  = p8
irel   = p9
iwav   = p10
ipw    = p11

itiestatus tieStatus
iskip   tival

tigoto skipInit
    ioldpch init ipch
    ioldamp init iamp 

skipInit:
inewpch = ipch
inewamp = iamp
;;kpchline  linseg  ioldpch, .05, inewpch, idur-.05,  inewpch
kpchline  linseg  ioldpch, .05, inewpch, idur-.05, inewpch
kampline  linseg  ioldamp, .05, inewamp, idur-.05, inewamp
ioldpch = inewpch
ioldamp = inewamp

if (itiestatus == -1) then
    kenv linsegr 0, irise, 1, irel, 0
elseif (itiestatus == 0) then   
    kenv linseg 0, irise, 1, 0, 1
elseif (itiestatus == 1) then
    kenv init 1
elseif (itiestatus == 2) then
    kenv linseg 1, idur-irel, 1, irel, 0
endif
aosc    vco2 kampline, kpchline, iskip+iwav, ipw
        zawm aosc*kenv*ipanl*imix, 1
	zawm aosc*kenv*ipanr*imix, 2 
        endin

	instr 4 ;;;; PAD synth
idur   = p3
ipch   = p5
iamp   = ampdb(p4 * 60 - 60)
ipanr  = sqrt(p6)
ipanl  = sqrt(1-p6)
imix   = p7
iatt   = p8
ilvl1  = p9
iswl   = p10
irel   = p11
iwav   = p12 ;;;see the vco2 page in the csound manual for description
ipw    = p13

kenv    expsegr 0.005, iatt, ilvl1, idur*iswl, iamp, idur - (idur*iswl), iamp, irel, 0.005
kjitter jspline .7, .4, 3
aosc1   vco2 .5, ipch, iwav, ipw, 0, .2
aosc2   vco2 .5, ipch*.998 + kjitter - 0.2, iwav, ipw, 0, .2
aosc3   vco2 .5, ipch*.999 - 0.1, iwav, ipw, 0, .2
aosc4   vco2 .5, ipch*1.001 + 0.1, iwav, ipw, 0, .2
aosc5   vco2 .5, ipch*1.002 + 0.2, iwav, ipw, 0, .2
asigl = aosc1*.707 + aosc3*.5 + aosc5*.866  
asigr = aosc1*.707 + aosc4*.574 + aosc2*.812
aoutl   butterlp asigl*0.025, 8000
aoutr   butterlp asigr*0.025, 8000
aoutr   delay aoutr, 0.007
        zawm aoutl*kenv*ipanl*imix, 1
	zawm aoutr*kenv*ipanr*imix, 2 
        endin

	instr 5 ;; Steven Yi\'s monosynth example
idur = abs(p3)   
ipch = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
iport init 0
iport = p8 ;;; I added this for pitch portamento, should be 0-1

itiestatus tieStatus
iskip   tival

tigoto skipInit
    ioldpch init ipch
    ioldamp init iamp 
    afeedback   init 0
skipInit:

inewpch = ipch
inewamp = iamp
if (iport==1) then
  kpchline linseg ioldpch, idur, inewpch, 0, inewpch
else
  kpchline linseg ioldpch, .05, inewpch, idur-.05, inewpch
endif
kampline  linseg  ioldamp, .05, inewamp, idur-.05, inewamp
ioldpch = inewpch
ioldamp = inewamp

if (itiestatus == -1) then
    kenv        adsr    .05, .05, 1, .05
elseif (itiestatus == 0) then   
    kenv        linseg  0, .05, 1,  .01, 1
elseif (itiestatus == 1) then
    kenv init 1
elseif (itiestatus == 2) then
    kenv linseg 1, idur-.05, 1, .05, 0
endif

kvibEnv linseg  0, .2, 3, idur - .2, 4
kvib    lfo     kvibEnv, 4.5
aout    vco2    kampline, kpchline + kvib, iskip
aout    moogladder  aout, 4000, 0.5, iskip
aout    = aout + afeedback
adelay  delay   aout * .2, 0.02
aout    = aout + adelay
afeedback = aout * .2
aoutl = aout * kenv * ipanl * imix
aoutr = aout * kenv * ipanr * imix
	zawm aoutl, 1
	zawm aoutr, 2
        endin

	instr 6 ;; pluck
idur = abs(p3)
ipch = p5
iamp = ampdb(p4 * 60 - 60) 
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
irel = p8
kenv linsegr 0, 0.001, 1, idur, 1, irel, 0
;;ares pluck kamp, kcps, icps, ifn, imeth [, iparm1] [, iparm2]
apluck  pluck iamp, ipch, ipch/2, 0, 2, 2
	zawm apluck*kenv*ipanl*imix, 1
	zawm apluck*kenv*ipanr*imix, 2
	endin

	instr 7  ;; fat moog w/o stereo swirlies
icps = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix  =  p7
iatt = .01
idec = 7
irel = .7
ifltamp = p4*4000 + 6500 ;;; used to be 8000
ifltdec = 6.8
;;; envelopes
kenv expsegr  0.001, iatt, iamp,    idec,   0.001, irel, 0.001
kfenv expsegr 0.001, iatt, ifltamp, ifltdec, 200, irel, 10
;;; fatten w/pulse width modulation
kpw	oscili	.3, 2.2, gisine  ;; pw (triangle /ramp) modulation -- try .4,.2,1
;; kres jspline kamp, kcpsMin, kcpsMax
kflmodm jspline .5, .4, 2   ;; for the stereo flangers
;; ares vco2 kamp, kcps [, imode] [, kpw] [, kphs] [, inyx]
aoscm	vco2  kenv,icps+kflmodm,0,kpw+.5,0, .333
afltm	moogvcf2 aoscm,kfenv,.45
asigr   delay afltm, 0.004
	zawm afltm*ipanl*imix, 1
	zawm asigr*ipanr*imix, 2
	endin

	instr 8 ;; Steven Yi\'s monosynth example, but no vibrato and brighter
idur = abs(p3)   
ipch = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
iport init 0
iport = p8 ;;; I added this for pitch portamento, '1' means full duration 
           ;;; portamento, anything else means use 'idefaultport' value in seconds
idefaultport = p9 ;;; portamento time value in seconds

itiestatus tieStatus
iskip   tival

tigoto skipInit
    ioldpch init ipch
    ioldamp init iamp 
    afeedback   init 0
skipInit:

inewpch = ipch
inewamp = iamp
if (iport==1) then
  kpchline linseg ioldpch, idur, inewpch, 0, inewpch
else
  kpchline linseg ioldpch, idefaultport, inewpch, idur-idefaultport, inewpch
endif
;;kampline  linseg  ioldamp, idefaultport, inewamp, idur-idefaultport, inewamp
kampline linseg ioldamp, idur, inewamp
ioldpch = inewpch
ioldamp = inewamp

if (itiestatus == -1) then
    kenv        adsr    .05, .05, 1, .05
elseif (itiestatus == 0) then   
    kenv        linseg  0, .05, 1,  .01, 1
elseif (itiestatus == 1) then
    kenv init 1
elseif (itiestatus == 2) then
    kenv linseg 1, idur-.05, 1, .05, 0
endif

asrc   vco2    kampline, kpchline, iskip
;aout    moogladder  aout, 6000, 0.4, iskip
;aout    moogladder  aout, 2000+(kampline*5000), 0.4, iskip
aflt    moogladder  asrc, 3000+(kampline*10000), 0.5, iskip
abut1   butterlp asrc, 600, 60
abut2   butterlp asrc, 1040, 70
abut3   butterlp asrc, 2250, 110
abut4   butterlp asrc, 2450, 120
abut5   butterlp asrc, 2750, 130
aout = aflt + abut1 + abut2*.2 + abut3*.125 + abut4*.125 + abut5*.00985  
aout    = aout + afeedback
adelay  delay   aout * .2, 0.02
aout    = aout + adelay
afeedback = aout * .2
aoutl = aout * kenv * ipanl * imix
aoutr = aout * kenv * ipanr * imix
	zawm aoutl, 1
	zawm aoutr, 2
        endin

	instr 9 ;;; advanced pluck
idur = abs(p3)
ipch = p5
iamp = ampdb(p4 * 60 - 60) 
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
ipchbuf = p8 
ifn = 0
imeth = p10
iparam1 = p11
iparam2 = p12
kcutoff = p13
kres = p14
kenv linsegr 0, 0.001, 1, idur, 1, 0.1, 0
axcite oscil 1, 1, gisine
apluck  pluck iamp, ipch, ipch*ipchbuf, ifn, imeth, iparam1, iparam2
aflt    moogladder apluck, kcutoff, kres
abal    balance aflt, apluck 
	zawm abal*kenv*ipanl*imix, 1
	zawm abal*kenv*ipanr*imix, 2
	endin

	instr 10 ;;; moderately simple FM instrument
;;; Classic carrier/modulator FM pair
;;; modulator and carrier both have envelopes
;;; there is also a biquad resonant LP cutoff filter (bqrez)
;;; plus modulator parameters are sensitive to both attack and pitch
;;; akin to keyboard "slope" parameters on a typical MIDI synth instrument
;;---------standard microcsound p-fields------;;
idur = abs(p3)
iamp = ampdb(p4 * 60 - 60)
ipch = p5
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
;;----extra p-fields, use dbl-quotes with '%' between parameters---;;
;;----to change from within microcsound------------------;;
imodratio = p8  ;; modulator ratio to carrier (carrier fixed at '1')
imoddepth = p9  ;; modulator max depth of modulation (controls 'brightness')
iatt = p10   ;; attack time in seconds
idec = p11   ;; decay time in seconds
isus = p12   ;; sustain level (0-1)
irel = p13   ;; release time in seconds
imodatt = p14 ;; mod attack time in seconds
imoddec = p15 ;; mod decay time in seconds
imodsus = p16 ;; mod sustain lvl, 0-1 
imodrel = p17 ;; mod release time in seconds
ifltcut = p18 ;; filter cutoff freq
ifltq = p19   ;; filter resonance ('Q') between 0-1
islpbase = p20 ;; base pitch in HZ to determine where modslope fulcrum point is
imodslope = p21 ;; changes the depth response according to pitch of base note (good values are -2 to 2)
ienvslope = p22 ;; changes the decay and release time according to pitch of base note (good values are -2 to 2)
ijitamt = p23 ;; jitter amount--produces rich stereo chorusing effect -- should be small, e.g. .001
ijitspd = p24 ;; maximum speed of jitter 'chorus' effect, try a value between 0 - 6
;;----------actual engine code starts here below--------------;;
islpnoteref = ipch/islpbase ;; reference ratio for pitch related modifications
if (islpnoteref < 1) igoto normal
   idepthslpmod 	pow islpnoteref, imodslope ;;change FM depth according to pitch
   ienvslpmod 	pow islpnoteref, ienvslope ;;change env decay and rel time according to pitch
   igoto going_on
normal:
  idepthslpmod = 1
  ienvslpmod = 1
going_on:
ksplineL jspline ijitamt, 0, ijitspd ;;adds rich stereo chorusing by slight pitch shifting
ksplineR jspline ijitamt, 0, ijitspd ;;on both channels -- disable by setting 'ijitamt' to 0
kenv expsegr (0.00001), iatt, (iamp), idec*ienvslpmod, (isus + 0.00001), irel*ienvslpmod, (0.00001)
kmodenv expsegr (0.00001), imodatt, (iamp*imoddepth*idepthslpmod), imoddec*ienvslpmod, (imodsus*imoddepth) + 0.00001, imodrel*ienvslpmod, (0.00001) 
;;; here\'s the template for the 'foscil' opcode:
;;;ar      foscil     xamp, kcps, kcar, kmod, kndx, ifn[, iphs]
;;; we use the carrier ratio of '1' here, and only move the base pitch and 
;;; modulator ratio:
aSigL foscil kenv, ipch*(1+ksplineL), 1, imodratio, kmodenv, gisine
aSigR foscil kenv, ipch*(1+ksplineR), 1, imodratio, kmodenv, gisine
;;; send the results of the FM oscillators through a bi-quad rezzy filter 
;;; to create something akin to a fixed resonant body. We can try some kind of
;;; bank of formant filters here in the future instead, but for now:
aFilterL bqrez aSigL, ifltcut, ifltq*100 
aFilterR bqrez aSigR, ifltcut, ifltq*100
	zawm  aFilterL*ipanl*imix, 1 ;;; send to the global mixer
	zawm  aFilterR*ipanr*imix, 2 ;;; ditto
	endin

	instr 11 ;; Legato formant synth, vocalise "Ahh", and gentle sawtooth layer.

idur = abs(p3)   
ipch = p5
iamp = (ampdb(p4 * 60 - 60))*.6
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
iport init 0
ivoicetype init 0
iport = p8 ;;; I added this for pitch portamento, '1' means full duration 
           ;;; portamento, anything else means use 'idefaultport' value in seconds
idefaultport = p9 ;;; portamento time value in seconds
ivoicetype = p10 ;;; 0=bass, 1=tenor, 2=alto, 3= soprano, all "ahhs"

itiestatus tieStatus
iskip   tival

tigoto skipInit
    ioldpch init ipch
    ioldamp init iamp 
    afeedbackL   init 0
    afeedbackR   init 0
skipInit:

inewpch = ipch
inewamp = iamp
if (iport==1) then
  kpchline linseg ioldpch, idur, inewpch, 0, inewpch
else
  kpchline linseg ioldpch, idefaultport, inewpch, idur-idefaultport, inewpch
endif
;;kampline  linseg  ioldamp, idefaultport, inewamp, idur-idefaultport, inewamp
kampline linseg ioldamp, idur, inewamp
ioldpch = inewpch
ioldamp = inewamp

; phase and mode of 'FOF':
iphs = 0
ifmode = 0

; work out tie stuff:
if (itiestatus == -1) then
    kenv        adsr    .05, .05, 1, .05
elseif (itiestatus == 0) then   
    kenv        linseg  0, .05, 1,  .01, 1
elseif (itiestatus == 1) then
    kenv init 1
elseif (itiestatus == 2) then
    kenv linseg 1, idur-.05, 1, .05, 0
endif

koct init 0
kris init 0.003
kdur init 0.02
kdec init 0.007
iolaps = 14850
ifna = gismallsine
ifnb = gisigmoid

;;; formants

if (ivoicetype == 0) then
  ; First formant.
  k1amp = ampdb(0)
  k1form init 600
  k1band init 60
  ; Second formant. 
  k2amp = ampdb(-7)
  k2form init 1040
  k2band init 70
  ; Third formant.
  k3amp = ampdb(-9)
  k3form init 2250
  k3band init 110
  ; Fourth formant.
  k4amp = ampdb(-9)
  k4form init 2450
  k4band init 120
  ; Fifth formant.
  k5amp = ampdb(-20)
  k5form init 2750
  k5band init 130
elseif (ivoicetype == 1) then
  ; First formant.
  k1amp = ampdb(0)
  k1form init 650
  k1band init 80
  ; Second formant. 
  k2amp = ampdb(-6)
  k2form init 1080
  k2band init 90
  ; Third formant.
  k3amp = ampdb(-7)
  k3form init 2650
  k3band init 120
  ; Fourth formant.
  k4amp = ampdb(-8)
  k4form init 2900
  k4band init 130
  ; Fifth formant.
  k5amp = ampdb(-22)
  k5form init 3250
  k5band init 140
elseif (ivoicetype == 2) then
  ; First formant.
  k1amp = ampdb(0)
  k1form init 800
  k1band init 50
  ; Second formant. 
  k2amp = ampdb(-4)
  k2form init 1150
  k2band init 60
  ; Third formant.
  k3amp = ampdb(-20)
  k3form init 2800
  k3band init 170
  ; Fourth formant.
  k4amp = ampdb(-36)
  k4form init 3500
  k4band init 180
  ; Fifth formant.
  k5amp = ampdb(-60)
  k5form init 4950
  k5band init 200
elseif (ivoicetype == 3) then
  ; First formant.
  k1amp = ampdb(0)
  k1form init 800
  k1band init 80
  ; Second formant. 
  k2amp = ampdb(-6)
  k2form init 1150
  k2band init 90
  ; Third formant.
  k3amp = ampdb(-32)
  k3form init 2900
  k3band init 120
  ; Fourth formant.
  k4amp = ampdb(-20)
  k4form init 3900
  k4band init 130
  ; Fifth formant.
  k5amp = ampdb(-50)
  k5form init 4950
  k5band init 140
endif

;; produce nice natural pitch instability for rich stereo chorusing
kjitL  jspline 0.0005*kpchline, .5, 4
kjitR  jspline 0.0005*kpchline, .5, 4

;; LEFT
asrcL   vco2  1, kpchline+kjitL, iskip
afltL   moogladder  asrcL, kpchline*(8+(kampline*8)), 0.666, iskip
afltL   moogladder  afltL, 11000, 0, iskip
a1L fof k1amp, kpchline+kjitL, k1form, koct, k1band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a2L fof k2amp, kpchline+kjitL, k2form, koct, k2band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a3L fof k3amp, kpchline+kjitL, k3form, koct, k3band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a4L fof k4amp, kpchline+kjitL, k4form, koct, k4band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a5L fof k5amp, kpchline+kjitL, k5form, koct, k5band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
;;; RIGHT
asrcR   vco2  1, kpchline+kjitR, iskip
afltR   moogladder  asrcR, kpchline*(8+(kampline*4)), 0.666, iskip
afltR   moogladder  afltR, 10000, 0, iskip
a1R fof k1amp, kpchline+kjitR, k1form, koct, k1band, kris, \
        kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a2R fof k2amp, kpchline+kjitR, k2form, koct, k2band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a3R fof k3amp, kpchline+kjitR, k3form, koct, k3band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a4R fof k4amp, kpchline+kjitR, k4form, koct, k4band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip
a5R fof k5amp, kpchline+kjitR, k5form, koct, k5band, kris, \
       kdur, kdec, iolaps, ifna, ifnb, idur, iphs, ifmode, iskip

;;; Combine all of the formants together.
aoutL = (afltL*2+a1L+a2L+a3L+a4L+a5L) * kampline
aoutR = (afltR*2+a1R+a2R+a3R+a4R+a5R) * kampline
;;;
aoutL   = aoutL + afeedbackL
aoutR	= aoutR + afeedbackR
adelayL  delay   aoutL * .2, 0.02
adelayR	 delay   aoutR * .2, 0.02
aoutL   = aoutL + adelayL
aoutR	= aoutR + adelayR
afeedbackL = aoutL * .2
afeedbackR = aoutR * .2
aoutL = aoutR * kenv * ipanl * imix
aoutR = aoutR * kenv * ipanr * imix
	zawm aoutL, 1
	zawm aoutR, 2
        endin

;------------------CHIPTUNE, second version, more controls----------------;
;------------------a filter, and richer stereo chrousing ---------------------------;

	instr 12

idur = abs(p3)
ipch = p5
iamp = ampdb(p4 * 60 - 60)
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix =  p7
iwav = p8
ipw  = p9
iatt = p10
idec = p11
isus = p12
irel = p13
;;;; filter cutoff min/max:
ifcmin = p14
ifcmax = p15
ifc = iamp*(ifcmax-ifcmin) + ifcmin
ifq = p16
ifatt = p17
ifdec = p18
ifsus = p19*ifc
ifrel = p20

itiestatus tieStatus
iskip   tival

tigoto skipInit
    ioldpch init ipch
    ioldamp init iamp 
skipInit:
inewpch = ipch
inewamp = iamp
inewfc = ifc
kpchline  linseg  ioldpch, .05, inewpch, idur-.05, inewpch
kampline  linseg  ioldamp, .05, inewamp, idur-.05, inewamp
ioldpch = inewpch
ioldamp = inewamp

if (itiestatus == -1) then
    kenv linsegr 0, iatt, 1, idec, isus, irel, 0
    kfltenv linsegr ifcmin, ifatt, ifc, ifdec, ifsus, ifrel, ifcmin 
elseif (itiestatus == 0) then   
    kenv linseg 0, iatt, 1, 0, 1
    kfltenv linseg ifcmin, ifatt, ifc, ifdec, ifsus 
elseif (itiestatus == 1) then
    kenv init 1
    kfltenv init ifsus
elseif (itiestatus == 2) then
    kenv linseg 1, idur-irel, isus, irel, 0
    kfltenv linseg ifsus, idur-irel, ifsus, irel, ifcmin
endif

kjitl jspline 0.4, 0.1, 0.2
kjitr jspline 1.5, 0.3, 0.21
aoscl   vco2 kampline, kpchline + kjitl, iskip+iwav, ipw
aoscr   vco2 kampline, kpchline + kjitr, iskip+iwav, ipw
afltl   moogladder aoscl, kfltenv, ifq
afltr   moogladder aoscr, kfltenv, ifq
        zawm afltl*kenv*ipanl*imix, 1
	zawm afltr*kenv*ipanr*imix, 2 
        endin

	instr 13 ;; sophisticated pluck/waveguide instrument

/* Fork of pluck/waveguide code originally from Victor Lazzarini */
/* ideas taken from 'guitar.csd' */

idur = p3
iamp = ampdb(p4 * 60 - 60)  /* amplitude (dB) */
ipch = p5                   /* fundamental */
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
	/* extra user parameters */
iatt = p8
idec = p9
isus = p10
irel = p11
iexccf = p12
iwgdec = p13	/* decay factor in dB/sec */
ipkpos = p14	/* pick-up position */
	/* end extra user parameters */

ipi = -4*taninv(-1)  /* constant for PI */
idts = sr/ipch       /* total delay time (samples) */
idtt = int(sr/ipch)  /* truncated delay time */
idel = idts/sr       /* delay time (secs) */
ifac init 1          /* decay shortening factor (fdb gain) */
is  init 0.5        /* loss filter coefficient */
igf pow 10, -iwgdec/(20*ipch) /* gain required for a certain decay */
ig  = cos(ipi*ipch/sr)       /* unitary gain with s=0.5 */

	/* conditional branching based on decay: */ 
if igf > ig igoto stretch /* if decay needs lengthening */
ifac = igf/ig             /* if decay needs shortening */
goto continue

stretch:       /* this is the LP coefficient calculation to
                  provide the required decay stretch */       
icosfun = cos(2*ipi*ipch/sr)
ia = 2 - 2*icosfun
ib = 2*icosfun - 2
ic = 1 - igf*igf 
id = sqrt(ib*ib - 4*ia*ic)
is1 = (-ib + id)/(ia*2)
is2 = (-ib - id)/(ia*2)
is = (is1 < is2 ? is1 : is2) 

continue:
ax1  init 0         /* filter delay variable */
apx1  init 0        /* allpass fwd delay variable */
apy1  init 0        /* allpass fdb delay variable */

idtt = ((idtt+is) > (idts) ? idtt - 1: idtt)
ifd = (idts - (idtt + is))  /* fractional delay */
icoef = (1-ifd)/(1+ifd)  /* allpass coefficient */

/* noise for excitation */
kexcenv linseg 0, iatt, iamp, idec, isus*iamp, \
                  idur-(iatt+idec+irel), isus*iamp, 0.01, 0
anoise pinkish kexcenv
aexcr tone anoise, iexccf
aexcr balance aexcr, anoise

/* wguide */
kwgamp expsegr 0.001, 0.001, iamp, idur-(iatt+irel), iamp, \
                      irel*2, 0.001  /* envelope */ 
adump  delayr 1
adel   deltapn idtt
aflt = (adel*(1-is) + ax1*is)*ifac /* LP filter   */
ax1 = adel
alps  = icoef*(aflt - apy1) + apx1  /* AP filter  */
apx1 = aflt
apy1 = alps
	/* pickup position stuff: */
ipkpr = (1-ipkpos)*idtt
ipkpl = ipkpos*idtt
ipkpr = (ipkpr == 0 ? ipkpl : ipkpr)
ipkpl = (ipkpl == 0 ? ipkpr : ipkpl)
apkupr deltapn ipkpr   /* right-going wave pickup */
apkupl deltapn ipkpl   /* left-going wave pickup */

  delayw alps+aexcr
aout dcblock (apkupr+apkupl)
	zawm  aout*kwgamp*ipanl*imix, 1
        zawm  aout*kwgamp*ipanr*imix, 2
	endin

	instr 14 ;; streson pad
idur = p3
iamp = ampdb(p4 * 60 - 60)
ifreq = p5
ipanr  = sqrt(p6)
ipanl  = sqrt(1-p6)
imix  =  p7
iatt = p8
irel = p9
iswl = idur * p10  ;; percent of duration spent swelling
ifdbgain = p11
imaindur = idur - iswl
;; the 'bow' is some pink noise:
asig pinkish iamp
aflt tone asig, 2000
kenv expsegr 0.005, iatt, iamp, idur-iatt, iamp, irel, 0.0005
kswl linsegr 0, iswl, 1, imaindur, 1, irel+0.01, 0
kjitter1 jitter .01, .1, 6.6
kjitter2 jitter .01, .11, 4.61
aresl streson aflt, ifreq + kjitter1, ifdbgain
aresr streson aflt, ifreq + ifreq*0.003 + kjitter2, ifdbgain
	zawm aresl*kenv*kswl*ipanl*imix, 1
	zawm aresr*kenv*kswl*ipanr*imix, 2
	endin


	instr 15 ;; another sophisticated pluck/waveguide instrument
	         ;; (modification of instr 13)

idur = p3
iamp = ampdb(p4 * 60 - 60)  /* amplitude (dB) */
ipch = p5                   /* fundamental */
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
	/* extra user parameters */
iatt = p8
idec = p9
isus = p10
irel = p11
iexccf = p12
iexccfhalf = iexccf * 0.5
iwgdec = p13	/* decay factor in dB/sec */
ipkpos = p14	/* pick-up position */
	/* end extra user parameters */

ipi = -4*taninv(-1)  /* constant for PI */
idts = sr/ipch       /* total delay time (samples) */
idtt = int(sr/ipch)  /* truncated delay time */
idel = idts/sr       /* delay time (secs) */
ifac init 1          /* decay shortening factor (fdb gain) */
is  init 0.5         /* loss filter coefficient */
igf pow 10, -iwgdec/(20*ipch) /* gain required for a certain decay */
ig  = cos(ipi*ipch/sr)        /* unitary gain with s=0.5 */

	/* conditional branching based on decay: */ 
if igf > ig igoto stretch /* if decay needs lengthening */
ifac = igf/ig             /* if decay needs shortening */
goto continue

stretch:       /* this is the LP coefficient calculation to
                  provide the required decay stretch */       
icosfun = cos(2*ipi*ipch/sr)
ia = 2 - 2*icosfun
ib = 2*icosfun - 2
ic = 1 - igf*igf 
id = sqrt(ib*ib - 4*ia*ic)
is1 = (-ib + id)/(ia*2)
is2 = (-ib - id)/(ia*2)
is = (is1 < is2 ? is1 : is2) 

continue:
ax1  init 0       /* filter delay variable */
apx1  init 0      /* allpass fwd delay variable */
apy1  init 0      /* allpass fdb delay variable */

idtt = ((idtt+is) > (idts) ? idtt - 1: idtt)
ifd = (idts - (idtt + is))  /* fractional delay */
icoef = (1-ifd)/(1+ifd)  /* allpass coefficient */

/* noise for excitation */
kexcenv linseg 0, iatt, iamp, idec, isus*iamp, \
                  idur-(iatt+idec), isus*iamp, 0.01, 0
anoise pinkish kexcenv
aexcr tone anoise, (iexccfhalf) + (iamp * iexccfhalf)
aexcr balance aexcr, anoise

/* wguide */
kwgamp expsegr 0.001, 0.001, iamp, idur-iatt, iamp, \
                      irel*2, 0.001  /* envelope */ 
adump  delayr 1
adel   deltapn idtt
aflt = (adel*(1-is) + ax1*is)*ifac /* LP filter   */
ax1 = adel
alps  = icoef*(aflt - apy1) + apx1  /* AP filter  */
apx1 = aflt
apy1 = alps
	/* pickup position stuff: */
ipkpr = (1-ipkpos)*idtt
ipkpl = ipkpos*idtt
ipkpr = (ipkpr == 0 ? ipkpl : ipkpr)
ipkpl = (ipkpl == 0 ? ipkpr : ipkpl)
apkupr deltapn ipkpr   /* right-going wave pickup */
apkupl deltapn ipkpl   /* left-going wave pickup */

  delayw alps+aexcr
aout dcblock (apkupr+apkupl)
	zawm  aout*kwgamp*ipanl*imix, 1
        zawm  aout*kwgamp*ipanr*imix, 2
	endin


	instr 16 ;; basic organ
idur = p3
iamp = ampdb(p4 * 60 - 60)  /* amplitude (dB) */
ipch = p5                   /* fundamental */
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
    /* user params */
ifltcf = p8
ifltq  = p9
    /* end user params */
kenv  linsegr 0, 0.01, iamp, 0, iamp, 0.02, 0
aorg  oscil kenv, ipch, giorgan
aflt  lowpass2 aorg, ifltcf, ifltq
	zawm  aflt*ipanl*imix, 1
        zawm  aflt*ipanr*imix, 2
	endin

;;;--------------DRUMS DRUMS DRUMS----------------;;;

	instr 100 ;simple kick drum
;; based on Rory Walsh\'s example, but with hard-coded values.
iamp = ampdb(p4 * 60 - 60)
idummy = p5
ipanr = sqrt(p6)
ipanl = sqrt(1-p6)
imix = p7
;;
kfrqswp  expon  97, .3, 42   		;; freq sweep
aenv     expon iamp*4, .4, 0.07	 	;; amp envelope
kdeclick linsegr 0, .01, 1, 0, 1, 0.01, 0
;; from the manual:
;; a/k/i/res poscil a/k/amp, a/k/cps [, ifn, iphs]
a1 poscil aenv, kfrqswp, gisine 	;; swept oscillator
	zawm a1*kdeclick*ipanl*imix, 1 
        zawm a1*kdeclick*ipanr*imix, 2
	endin

;--------Joaquin\'s snare
		instr 101
idur = .25  ;p3
iamp = ampdb(p4*60 - 60)
idummy = p5
ipanr = p6
ipanl = (1-p6)
imix  =  p7 * .6 ;;fool around with this -- used to be .25
atri  oscil3  1, 111, gitri  ;triangle wave	
areal, aimag hilbert atri

ifshift =      175
asin    oscil3 1, ifshift, gisine	
acos    oscil3 1, ifshift, gisine, .25	
amod1   =      areal * acos
amod2   =      aimag * asin
ashift1 =      ( amod1 + amod2 ) * 0.7

ifshift2 =      224
asin     oscil3 1, ifshift2, gisine	
acos     oscil3 1, ifshift2, gisine, .25	
amod1    =      areal * acos
amod2    =      aimag * asin
ashift2  =      ( amod1 + amod2 ) * 0.7

kenv1     linseg 1, 0.15, 0, idur - 0.15, 0
ashiftmix =      ( ashift1 + ashift2 ) * kenv1

aosc1   oscil3 1, 180, gisine
aosc2   oscil3 1, 330, gisine
kenv2   linseg 1, 0.08, 0, idur - 0.08, 0
aoscmix =      ( aosc1 + aosc2 ) * kenv2

anoise gauss    1
anoise butterhp anoise, 2000
anoise butterlp anoise, 8000
anoise butterbr anoise, 4000, 200
kenv3  expseg   2, 0.15, 1, idur - 0.15, 1
anoise =        anoise * ( kenv3 - 1 )

amix = aoscmix + ashiftmix + anoise * 4

kenv4 linseg 0, 0.01, 1, idur - 0.02, 1, 0.01, 0
amix  =      amix * kenv4

	zawm amix*iamp*ipanl*imix, 1
	zawm amix*iamp*ipanr*imix, 2
endin

;------	HI-HAT CYMBAL CLOSED ------; cymbal

	instr 102
;idur = p3
iamp = ampdb(p4 * 60 - 60)
idummy = p5
ipanr = p6
ipanl = (1-p6)
imix  =  p7
kenv  oscil1  0, iamp, .1, gioneshot1
anois rand  kenv
aosc  oscil kenv*.2, 2346, gisine
afilt butterhp anois+aosc, 2500
afilt butterhp afilt, 2500
;;I added this for more brightness. -AKJ
afilt2 butterhp afilt*.1, 14000, 400
	zawm (afilt+afilt2)*ipanl*imix, 1
	zawm (afilt+afilt2)*ipanr*imix, 2
	endin 

;------ HI-HAT CYMBAL OPEN ---------;

	instr 103
idur = p3
iamp = ampdb(p4 * 60 - 60)
idummy = p5
ipanr = p6
ipanl = (1-p6)
imix  =  p7
kenv  oscil1  0, iamp, 1.1, gioneshot1
kenv2 linseg 0, .001, 1, idur-.1, 1, .1, 0
anois rand  kenv*kenv2
aosc  oscil kenv*.2, 2346, gisine
afilt butterhp anois+aosc, 2500
afilt butterhp afilt, 2500
afilt2 butterhp afilt*.1, 14000, 400
	zawm (afilt+afilt2)*ipanl*imix, 1
	zawm (afilt+afilt2)*ipanr*imix, 2
	endin 

;---------------------------------------------------------
; Formant pop
;---------------------------------------------------------
       instr     104

idur   =         p3            ; Duration
iamp   =         ampdb(p4 * 60 - 60)         ; Amplitude
ifqc   =         p5
ipanr  = 	 p6
ipanl  =	 (1-p6)
imix   =         p7
if1    =         p8*ifqc       ; Formant fqc 1
ia1    =         p9            ; Formant amp 1
iwdth  =         p10*.1         ; Band width

adclck linseg    0, .002, 1, idur-.007, 1, .005, 0 ; Declick envelope
kamp   linseg    0, .002, 1, .007, 0, idur-.009, 0

arnd   rand      kamp*6/iwdth                      ; Genrate impulse
asig   butterbp  arnd, ifqc, ifqc*iwdth            ; Band pass filter
asig1  butterbp  arnd, if1,  if1*iwdth             ; Band pass filter

aout   =         (asig+asig1*ia1)*iamp*adclck      ; Apply amp envelope and declick

       zawm      aout*ipanl*imix, 1
       zawm      aout*ipanr*imix, 2

       endin

;==========
; NOIZ 02
;==========
	instr 105

iamp =  ampdb(p4 * 60 - 60)					
inote = p5					
ipanr = p6
ipanl = (1-p6)
imix  =  p7
k1 linseg 1, .05, 100, .2, 100, 2, 1, p3, 1 
k2 rand 500, 1
a1 buzz iamp*.3, inote, k1, gisine
a2 buzz iamp, inote*.5, k1, gisine
a3 buzz iamp, inote*.501, k1, gisine

a4 oscil (a1+a2+a3)*.3, k2, gisine

	zawm a4*ipanl*imix, 1
	zawm a4*ipanr*imix, 2
	endin

;==========
; DRUM  pitched drum spinoff from J. ffitch
;==========

	instr 106

idur  =  p3						;p5=pitch in cps
iamp1 =  ampdb(p4 * 60 - 60)						;p4=amp
iamp2 =  iamp1 * .3					;p6=panning
iamp3 =  iamp1 * .8					;p8=extra pitch in cps
ifreq =  p5
ipanr = p6
ipanl = (1-p6)
imix  =  p7
ifreq2 = p8
         a5     randi   iamp1, 1500
         a5     oscili  a5, 1/idur, gioneshot2
         a5     oscili  a5, p5*1.006, gisine

         a3     oscili  iamp2, 1/idur, gioneshot2
         a3     oscili  a3, 33.1, gisnare

         a1     oscili  iamp3, 1/idur, gioneshot1
         a1     oscili  a1,  p8*.998, gisine

 aout = ((a1+a3+a5)*.5)

        zawm    aout*ipanl*imix, 1
	zawm	aout*ipanr*imix, 2
endin

	instr 107 ;;; shaker
iamp = ampdb(p4 * 60 - 60)
ipanL = sqrt(p6)
ipanR = sqrt(1-p6)
imix = p7
ipch = 6073
ibeans = 22
idmp = 0.98
ishak = 0
ashake shaker iamp, ipch, ibeans, idmp, ishak
	zawm ashake*ipanL*imix, 1
	zawm ashake*ipanR*imix, 2
	endin

;-----VIRTUAL DRUMKIT-----;

	instr 120
idur    =  p3
iwhich	=  p5+100
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
 kdry    =    1
 kwet	 =   .5
 kroom   =   .7
 kfco    =   7000
 goto out_stuff

zak_stuff:
 kdry	zkr	0
 kwet	zkr	1
 kroom	zkr	2
 kfco	zkr	3
 goto out_stuff

out_stuff:
	denorm aleft, aright
alv, arv reverbsc aleft, aright, kroom, kfco, sr, 0.7, 1
alpost = (aleft*kdry + alv*kwet)
arpost = (aright*kdry + arv*kwet)
iqvar = 1.414
ivol1 = ampdb(-1)
ivol2 = ampdb(-1)
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

;; end of instruments ;;
 