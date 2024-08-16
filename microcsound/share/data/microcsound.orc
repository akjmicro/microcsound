sr      =  44100
ksmps   =  128
nchnls  =  2
0dbfs   =  1

gabusL  init    0 
gabusR  init    0

;; mixer variables, controlled by instr 202
gkdry           init        1
gkwet           init        0
gkroomsize      init        0.75
gkroomfco       init        7000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Deliberately low-fi-ish (8-bitish) Tables                 ;;;          
;;; gir ftgen ifn, itime, isize, igen, iarga [, iargb ] [...] ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gisine          ftgen           1,  0,  256,  10,  1
gitri           ftgen           2,  0,  256,  7,   0,  64,   1,  128,  -1,  64,   0
gisaw           ftgen           3,  0,  256,  7,   0,  128,  1,  0,    -1,  128,  0
gisquare        ftgen           4,  0,  256,  7,   1,  128,  1,  0,    -1,  128,  -1
giquarter       ftgen           5,  0,  256,  7,   1,  64,   1,  0,    -1,  192,  -1
gieighth        ftgen           6,  0,  256,  7,   1,  32,   1,  0,    -1,  224,  -1

;;; sine for vco
gibigsine       ftgen           7, 0, 65536, 10, 1   ;; sine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ------------now the UDOs and instruments ----------- ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Steven Yi\'s tie opcode ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
opcode tieStatus,i,0
                    itie            tival
        if (p3 < 0 && itie == 0) ithen
    ; this is an initial note within a group of tied notes
    itiestatus      =               0
        elseif (p3 < 0 && itie == 1) ithen
    ; this is a middle note within a group of tied notes
    itiestatus      =               1
        elseif (p3 > 0 && itie == 1) ithen
    ; this is an end note out of a group of tied notes
    itiestatus      =               2
        elseif (p3 > 0 && itie == 0) ithen
    ; this note is a standalone note
    itiestatus      =               -1
    endif
                    xout            itiestatus
endop

instr 1    ;;;-- basic waveforms for 8-bit music --;;;
    idur            =               p3
    ipch            =               p5
    ;;; putting this first b/c it affects the iamp factor:
    iwav            =               p8
        if (iwav == 1) then
    icorrection     =               1
        elseif (iwav == 2) then
    icorrection     =               0.95
        elseif (iwav == 3) then
    icorrection     =               0.93
        elseif (iwav == 4) then
    icorrection     =               0.86
        else
    icorrection     =               0.84
        endif
    iamp            =               ampdbfs(p4) * icorrection
    ipanr           =               sqrt(p6)
    ipanl           =               sqrt(1-p6)
    imix            =               ampdbfs(p7)
    iatt            =               p9
    idec            =               p10
    isus            =               p11
    irel            =               p12
    ;;; legato stuff:
                    itiestatus      tieStatus
                    tigoto          skipInit
    ioldpch         init            ipch
    ioldamp         init            iamp
        skipInit:
    inewpch         =               ipch
    inewamp         =               iamp
    kpchline        linseg          ioldpch,  .01,  inewpch,  idur-.01,  inewpch
    kampline        linseg          ioldamp,  .01,  inewamp,  idur-.01,  inewamp
    ioldpch         =               inewpch
    ioldamp         =               inewamp
        if (itiestatus == -1) then
    kenv            linsegr         0, iatt, iamp, idec, isus*iamp, irel, 0
        elseif (itiestatus == 0) then
    kenv            linseg          0, iatt, iamp, 0, iamp
        elseif (itiestatus == 1) then
    kenv            init            iamp
        elseif (itiestatus == 2) then
    kenv            linseg          iamp, idur-irel, iamp, irel, 0
        endif
    ;; end legato stuff
    aout            oscil           kenv * kampline, kpchline, iwav, -1
    gabusL          +=              aout * ipanl * imix * icorrection
    gabusR          +=              aout * ipanr * imix * icorrection
endin

instr 2    ;;; FM instrument (somewhat complex, 17 user params)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Classic carrier/modulator FM pair. Modulator and carrier both have envelopes. ;;;
    ;;; There is also a biquad resonant LP cutoff filter (bqrez), plus modulator      ;;;
    ;;; parameters are sensitive to both attack and pitch akin to keyboard "slope"    ;;;
    ;;; parameters on a typical MIDI synth instrument                                 ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;---------standard microcsound p-fields------;;
    idur            =               abs(p3)
    iamp            =               ampdbfs(p4)
    ipch            =               p5
    ipanr           =               sqrt(p6)
    ipanl           =               sqrt(1-p6)
    imix            =               ampdbfs(p7)
    ;;----extra p-fields, use dbl-quotes with '%' between parameters---;;
    ;;----to change from within microcsound------------------;;
    imodratio       =               p8    ;; modulator ratio to carrier (carrier fixed at '1')
    imoddepth       =               p9    ;; modulator max depth of modulation (controls 'brightness')
    iatt            =               p10   ;; attack time in seconds
    idec            =               p11   ;; decay time in seconds
    isus            =               p12   ;; sustain level (0-1)
    irel            =               p13   ;; release time in seconds
    imodatt         =               p14   ;; mod attack time in seconds
    imoddec         =               p15   ;; mod decay time in seconds
    imodsus         =               p16   ;; mod sustain lvl, 0-1 
    imodrel         =               p17   ;; mod release time in seconds
    ifltcut         =               p18   ;; filter cutoff freq
    ifltq           =               p19   ;; filter resonance ('Q') between 0-1
    islpbase        =               p20   ;; base pitch in HZ to determine where modslope fulcrum point is
    imodslope       =               p21   ;; changes the depth response according to pitch of base note (good values are -2 to 2)
    ienvslope       =               p22   ;; changes the decay and release time according to pitch of base note (good values are -2 to 2)
    ijitamt         =               p23   ;; jitter amount--produces rich stereo chorusing effect -- should be small, e.g. .001
    ijitspd         =               p24   ;; maximum speed of jitter 'chorus' effect, try a value between 0 - 6
    ;;----------actual engine code starts here below--------------;;
    islpnoteref     =               ipch / islpbase          ;; reference ratio for pitch related modifications
        if (islpnoteref < 1) igoto normal
    idepthslpmod    pow             islpnoteref, imodslope   ;; change FM depth according to pitch
    ienvslpmod      pow             islpnoteref, ienvslope   ;; change env decay and rel time according to pitch
                    igoto           going_on
        normal:
    idepthslpmod    =               1
    ienvslpmod      =               1
        going_on:
    ksplineL        jspline         ijitamt, 0, ijitspd     ;; adds rich stereo chorusing by slight pitch shifting
    ksplineR        jspline         ijitamt, 0, ijitspd     ;; on both channels -- disable by setting 'ijitamt' to 0
    kenv            expsegr         (0.00001), iatt, (iamp), idec*ienvslpmod, (isus + 0.00001), irel*ienvslpmod, (0.00001)
    kmodenv         expsegr         (0.00001), imodatt, (iamp*imoddepth*idepthslpmod), imoddec*ienvslpmod, \
                                        (imodsus*imoddepth) + 0.00001, imodrel*ienvslpmod, (0.00001)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; We use the carrier ratio of '1' here, and only move the base pitch and ;;;
    ;;; modulator ratio:                                                       ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    aSigL           foscil          kenv, ipch*(1+ksplineL), 1, imodratio, kmodenv, gisine
    aSigR           foscil          kenv, ipch*(1+ksplineR), 1, imodratio, kmodenv, gisine
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Send the results of the FM oscillators through a bi-quad rezzy filter      ;;;
    ;;; to create something akin to a fixed resonant body. We can try some kind of ;;;
    ;;; bank of formant filters here in the future instead, but for now:           ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    aFilterL        bqrez           aSigL, ifltcut, ifltq*100
    aFilterR        bqrez           aSigR, ifltcut, ifltq*100
    gabusL          +=              aFilterL*ipanl*imix    ;;; send to the global mixer
    gabusR          +=              aFilterR*ipanr*imix    ;;; ditto
endin

instr 3   ;;; 'brassy' instrument using sawtooth from vco
    ;;;;;;;;;;;;;;;;;;;;;;;
    ;;; variables setup ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;
    iamp            =               ampdbfs(p4)
    icps            =               p5
    ipan            =               p6
    imix            =               ampdbfs(p7)
    ibrmin          =               p8
    ibrmax          =               p9
    iatt            =               p10
    irel            =               p11
    ipchmul         =               p12
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; intermediate calcs ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ibrightmin      =               icps * ibrmin * iamp
    ibrightmax      =               icps * ibrmax * iamp
    ;;;;;;;;;;;;;
    ;;; audio ;;;
    ;;;;;;;;;;;;;
    kndxenv         expsegr         (ibrightmin), iatt, (ibrightmax), irel*5, (ibrightmin), irel, (ibrightmin)
    aenv            expsegr         (0.01), iatt, iamp*2.9, irel, (0.01)
    aenv            =               aenv - 0.01
    asig            vco             1, icps*ipchmul, 0, 0.98, gibigsine
    asig            tonex           asig * aenv, kndxenv, 3
    asig            dcblock2        asig
    asigL, asigR    pan2            asig, ipan
    gabusL          +=              asigL * imix
    gabusR          +=              asigR * imix
endin

instr 4    ;;; 'brassy' instrument using FM 'foscili'
    ;;;;;;;;;;;;;;;;;;;;;;;
    ;;; variables setup ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;
    iamp            =               ampdbfs(p4)
    icps            =               p5
    ipan            =               p6
    imix            =               ampdbfs(p7)
    ibrightmin      =               p8
    ibrightmax      =               p9
    iatt            =               p10
    irel            =               p11
    ifmcar          =               1
    ifmmod          =               1
    ifmtab          =               1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; intermediate calcs ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ibright         =               (ibrightmax - ibrightmin) * iamp
    ;;;;;;;;;;;;;
    ;;; audio ;;;
    ;;;;;;;;;;;;;
    kndxenv         expsegr         ibrightmin, iatt, ibright, irel, ibrightmin
    aaenv           expsegr         0.01, iatt, iamp, irel, 0.01
    aaenv           =               aaenv - 0.01
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; FM foscili opcode is:                                   ;;;
    ;;; ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs] ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    asig            foscili         aaenv, icps, ifmcar, ifmmod, kndxenv, ifmtab, -1
    asig            lowpass2        asig, 8192, 40
    asig            dcblock2        asig
    asigL, asigR    pan2            asig, ipan
    gabusL          +=              asigL * imix
    gabusR          +=              asigR * imix
endin

instr 5    ;;; Plucked, clav-like instrument, using `faust_wguide`.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; `faust_wguide`, as the name implies, was designed in `faust`, ;;;
    ;;; and added as an opcode to `diet_csound`.                      ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    iamp            =               ampdbfs(p4)
    icps            =               p5
    ipan            =               p6
    imix            =               ampdbfs(p7)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; superpluck params -- at some point, there may be a version of ;;;
    ;;; this where these variables are fed in from the score.         ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; keyboard tracking
    itrack          =               log2(icps * 0.015625) * 0.25
    ires            =               31
    iexcmin         =               0.001
    irndattime      rnd             812
    iexctime        =               0.007
    ;;; envelope
    iatt            =               0.005
    ifcdecmin       =               7
    ifcdecmax       =               5
    ifcdectrack     =               (ifcdecmax - ifcdecmin) * itrack
    ifcdec          =               ifcdecmin + ifcdectrack
    irel            =               0.03
    ;;; filter
    icutoff_min     =               850
    icutoff_max     =               4500
    icutoff_track   =               (icutoff_max - icutoff_min) * iamp
    icutoff_range   =               icutoff_min + icutoff_track
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; actual sounding stuff, a 'superpluck' tone generator ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; excitation
    anoise          rand            iamp
    afltnoise       butlp           anoise, icutoff_range * 2 + icutoff_min
    aexc            balance2        afltnoise, anoise
    kexcenv         expsegr         iexcmin, iexctime, iamp, iexctime, iexcmin, iexctime, iexcmin
    kexcenv         =               kexcenv - iexcmin
    ;;; feed excitation signal to waveguide
    asig            faust_wguide    aexc * kexcenv, icps, ires
    ;;; amp and filter envelopes
    kenv            expsegr         iexcmin, iatt, iamp, irel, iexcmin
    kenv            =               kenv - iexcmin
    kfenv           expsegr         iexcmin, iatt, 1, ifcdec, iexcmin, irel, iexcmin
    kfenv           =               kfenv - iexcmin
    ksweep          =               (kfenv * iamp * icutoff_range) + icutoff_min
    aflt            butlp           asig * kenv, ksweep
    aflt            butlp           aflt, ksweep
    ;;; renormalize/balance the signal
    aout            balance2        aflt, asig
    aoutL, aoutR    pan2            aout, ipan
    aoutL           dcblock2        aoutL
    aoutR           dcblock2        aoutR
    gabusL          +=              aoutL * imix
    gabusR          +=              aoutR * imix
endin

;;;;;;;;;;;;;
;;; DRUMS ;;;
;;;;;;;;;;;;;

instr 100    ;;;--kick--;;;
    idur            =               p3
    ipch            =               p5
    iamp            =               ampdbfs(p4)
    ipanr           =               sqrt(p6)
    ipanl           =               sqrt(1-p6)
    imix            =               ampdbfs(p7)
    istartpitch     =               100
    iendpitch       =               47
    iampscale       =               2.1
    idecay          =               0.2
    k1              expon           istartpitch,  idecay,  iendpitch
    aenv            expon           iamp,         idecay,  0.001
    a1              poscil          aenv,         k1,          2
    gabusL          +=              a1 * ipanl * imix * iampscale
    gabusR          +=              a1 * ipanr * imix * iampscale
endin

instr 101    ;;;--snare--;;;
    idur            =               p3
    ipch            =               p5
    iamp            =               ampdbfs(p4)
    ipanr           =               sqrt(p6)
    ipanl           =               sqrt(1-p6)
    imix            =               ampdbfs(p7)
    iampscale       =               0.8
    idecay          =               0.1
    islope          =               0.1
    aenv            expon           iamp, idecay, iamp * islope
    a1              oscili          aenv, 147, 1
    arand           rand            aenv
    gabusL          +=              (a1 + arand) * ipanl * imix * iampscale
    gabusR          +=              (a1 + arand) * ipanl * imix * iampscale
endin

instr 102    ;;;--hihat closed--;;;
    idur            =               p3
    ipch            =               p5
    iamp            =               ampdbfs(p4)
    ipanr           =               sqrt(p6)
    ipanl           =               sqrt(1-p6)
    imix            =               ampdbfs(p7)
    iampscale       =               1.3
    idecay          =               0.06
    islope          =               0.06
    aamp            expon           iamp, idecay, iamp*islope
    arand           rand            aamp
    gabusL          +=              arand * ipanl * imix
    gabusR          +=              arand * ipanl * imix
endin

instr 103    ;;;--hihat open--;;;
    idur            =               p3
    ipch            =               p5
    iamp            =               ampdbfs(p4)
    ipanr           =               sqrt(p6)
    ipanl           =               sqrt(1 - p6)
    imix            =               ampdbfs(p7)
    iampscale       =               0.9   ;; used to be 0.5
    islope          =               0.2
    idecay          =               0.2
    aamp            expon           iamp, idecay, iamp * islope
    arand           rand            aamp
    gabusL          +=              arand * ipanl * imix * iampscale
    gabusR          +=              arand * ipanl * imix * iampscale
endin

instr 120    ;;;-----VIRTUAL DRUMKIT-----;;;
    idur            =               p3
    iwhich          =               p5 + 100  ;;add two to get the instrument
    iamp            =               p4
    ipan            =               p6
    imix            =               p7
                    event_i         "i", iwhich, 0, idur, iamp, iwhich, ipan, imix
endin

;------------------------;
;-------MIXER/REVERB-----;
;------------------------;

instr 200   ;;; main reverb global effects sink/output bus. Never call this directly!
    ;;;; actual audio:
    alrev, arrev    reverbsc        gabusL, gabusR, gkroomsize, gkroomfco, sr, 0.7, 1
    alpost          =               (gabusL*gkdry + alrev*gkwet)
    arpost          =               (gabusR*gkdry + arrev*gkwet)
    ;; send to output
                    outs            alpost*0.8, arpost*0.8
    gabusL          =               0
    gabusR          =               0
endin

instr 201  ;;; init instrument 200 (use this directly to initialize the mixer
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Since microcsound has no way of defining infinite "always-on" duration,  ;;;
    ;;; we trigger an "always-on" instrument via `event_i`, indirectly.          ;;;
    ;;; This translates to: to turn the master bus mixer on, use instrument 201. ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; notice p4, p6, and p7 are ignored
    kon             =               p5
                    event_i         "i", 200, 0 , -1
endin

instr 202  ;;; master mixer controls
    ;;; notice p4, p6, and p7 are ignored.
    ktrig           =               p5   ;;; p5 is a dummy trigger field, use '1' to activate controls
    kdry            =               p8   ;;; dry volume
    kwet            =               p9   ;;; wet volume
    kroom           =               p10  ;;; room size
    kfco            =               p11  ;;; room freq damp
    ;; set globals
    gkdry           =               kdry
    gkwet           =               kwet
    gkroomsize      =               kroom
    gkroomfco       =               kfco
endin
