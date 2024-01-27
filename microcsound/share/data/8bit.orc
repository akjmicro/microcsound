sr      =  44100
ksmps   =  128
nchnls  =  2
0dbfs   =  1

;;; some function tables (known as "f-tables" in Csound speak) are set up here:
;;; gir ftgen ifn, itime, isize, igen, iarga [, iargb ] [...]
gisine     ftgen  1,  0,  256,  10,  1
gitri      ftgen  2,  0,  256,  7,   0,  64,   1,  128,  -1,  64,   0
gisaw      ftgen  3,  0,  256,  7,   0,  128,  1,  0,    -1,  128,  0
gisquare   ftgen  4,  0,  256,  7,   1,  128,  1,  0,    -1,  128,  -1
giquarter  ftgen  5,  0,  256,  7,   1,  64,   1,  0,    -1,  192,  -1
gieighth   ftgen  6,  0,  256,  7,   1,  32,   1,  0,    -1,  224,  -1

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

;;;

instr 1   ;-- basic waveforms for 8-bit music --;
    idur =  p3
    ipch =  p5
    ;;; putting this first b/c it affect the iamp factor:
    iwav =  p8
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
    iamp  =  ampdb((p4 * icorrection * 60) - 60)
    ipanr =  sqrt(p6)
    ipanl =  sqrt(1-p6)
    imix  =  p7
    iatt  =  p9
    idec  =  p10
    isus  =  p11
    irel  =  p12

    ;;; legato stuff:
    itiestatus tieStatus

    tigoto skipInit
        ioldpch init ipch
        ioldamp init iamp
    skipInit:
    inewpch   =       ipch
    inewamp   =       iamp
    kpchline  linseg  ioldpch,  .01,  inewpch,  idur-.01,  inewpch
    kampline  linseg  ioldamp,  .01,  inewamp,  idur-.01,  inewamp
    ioldpch   =       inewpch
    ioldamp   =       inewamp

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

    aout  oscil  kenv * kampline, kpchline, iwav, -1
	        outs   aout * ipanl * imix * icorrection,
                 aout * ipanr * imix * icorrection
endin

;;;;;;;;;;;;;
;;; DRUMS ;;;
;;;;;;;;;;;;;

instr 2   ;--kick--;
    idur         =       p3
    ipch         =       p5
    iamp         =       ampdb(p4 * 60 - 60)
    ipanr        =       sqrt(p6)
    ipanl        =       sqrt(1-p6)
    imix         =       p7
    istartpitch  =       120
    iendpitch    =       70
    iampscale    =       1.1
    k1           expon   istartpitch,  idur + 0.1,  iendpitch
    aenv         expon   iamp,         idur + 0.1,  0.001
    a1           poscil  aenv,         k1,          2
                 outs    a1 * ipanl * imix * iampscale,
                         a1 * ipanr * imix * iampscale
endin

instr 3   ;--snare--;
    idur        =       p3
    ipch        =       p5
    iamp        =       ampdb(p4 * 60 - 60)
    ipanr       =       sqrt(p6)
    ipanl       =       sqrt(1-p6)
    imix        =       p7
    iampscale   =       0.5
    idecay      =       0.1
    islope      =       0.1
    aenv        expon   iamp, idecay, iamp * islope
    a1          oscili  aenv, 147, 1
    arand       rand    aenv
                outs    (a1 + arand) * ipanl * imix * iampscale,
                        (a1 + arand) * ipanl * imix * iampscale
endin

instr 4   ;--hihat closed--;
    idur    =       p3
    ipch    =       p5
    iamp    =       ampdb(p4 * 60 - 60)
    ipanr   =       sqrt(p6)
    ipanl   =       sqrt(1-p6)
    imix    =       p7
    idecay  =       0.06
    islope  =       0.06
    aamp    expon   iamp, idecay, iamp*islope
    arand   rand    aamp
            outs    arand * ipanl * imix,
                    arand * ipanl * imix
endin

instr 5   ;--hihat open--;
    idur       =      p3
    ipch       =      p5
    iamp       =      ampdb(p4 * 60 - 60)
    ipanr      =      sqrt(p6)
    ipanl      =      sqrt(1 - p6)
    imix       =      p7
    iampscale  =      0.6   ;; used to be 0.5
    islope     =      0.2
    idecay     =      0.2
    aamp       expon  iamp, idecay, iamp * islope
    arand      rand   aamp
               outs   arand * ipanl * imix * iampscale,
                      arand * ipanl * imix * iampscale
endin

instr 10 ;-----VIRTUAL DRUMKIT-----;
    idur    =         p3
    iwhich	=         p5 + 2  ;;add two to get the instrument
    iamp    =         p4
    ipan    =         p6
    imix    =         p7
            event_i   "i", iwhich, 0, idur, iamp, iwhich, ipan, imix
endin
