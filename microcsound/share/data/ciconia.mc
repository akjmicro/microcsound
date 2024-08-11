############################################################################
### Johannes Ciconia "Et in Terra Pax" as a chiptune, w/Drum arrangement ###
############################################################################
### Main mixer setup - for this piece, no reverb
### The `&-1` rewinds the time, allowing instrument 201 and 202 to be
### triggered at the same time. Whatespace isn't significant, but serves
### To highlight the two mixer setup statments
1: div=0 i=201 1    &-1    i=202 "1.0%0.0%0.0%0.0" 1  &-1
### Instrument setup
1: i=1.1 "3%0.01%0%1%0.2" pan=0.9 mix=1.2 div=53 gs=10.6 r3 @7
2: i=1.2 "4%0.01%0%1%0.2" pan=0.1 mix=1.5 div=53 gs=10.6 r3 @74
3: i=1.3 "2%0.01%0%1%0.2" pan=0.5 mix=1.4 div=53 gs=10.6 r3 @76
4: i=100 mix=0.25 pan=0.5 div=0 r3
5: i=100 mix=0.3 pan=0.5 div=0 r3
### The pre-chant:
1: t=140 1/5 g e g (g a b c' a g a g2) e2 f2 g4 r r r t=120
2: 23/5 r
3: 23/5 r
4: 23/5 r 
5: 23/5 r
### Et in terra pax:
1: t=147 
1: 1/8    c'6         | b2 c' b2 a  | c'5       r |
2: 1/8    g3r     a2  | g2  f e2 d  | f5        r |
3: 1/8    c6          | g,4    g,2  | f,5       r |
4: 1/8 @8 0 r 1 r r r | 0 r 1 r r 0 | 0 r 1 r r 0 |
5: 1/8 @7 r 2 r 2 r 2 | r 2 r 3 2 r | r 2 r 2 r 2 |
### Pax:
1: c'r r2 r2   | d'r r2  r2  |  c'3 g2 a    |  b5 r       |
2: r2  ar r2   | r2  br  r2  |  g2  a2 g2   |  ^f5 r      |
3: r2  r2 fr   | r2  r2  gr  |  c2  f2 e2   |  d5 r       |
4: 0 r r r r r | 0 r r r r r |  0 r 1 r 0 r | 0 r r 1 r r |
5: r 3 2 r r r | r 3 2 r r r |  r 3 2 r r 2 | r 2 r 2 r 2 |
### bonae (m. 8)
1: c'2 a2 b2 | c'2 d'c' _ba  | g2f e2d     | f5  r  |
2: g2  ^f4   | g4        a2  | bc' d'c'2 b | c'4 r2 |
3: c2  d2 r2 | c4        c2  | g,6         | f,5 r  |
4: 0 r 0 r r r | 0 r r 1 r r | 0 r 0 r r r | 0 r r 1/16 1 1 1/8 r 1 |
5: r 2 r 2 r 2 | r 2 r 2 r 3 | r 2 r 2 r 3 | r 2 r      2       r 2 |
### Laudamus te
1: r6          | c'2 a2  b2  | c'4     bc'        |     d'2d   c'2b          |
2: a2  g2   f2 | e2  g^f2e   | g6                 |     r2  fg   ag          |
3: f3    efd   | c2  d3   r  | c4      e2         |     de  f2   e2          |
4: 0 r 1 r r 0 | 0 r r 1 r 0 | 0 r r 1 r 1/16 1 1 | 1/8 0 r 0 r r 1/24 1 1 1 |
5: r 2 r 3 2 r | r 2 r 2 r 2 | r 2 r 2 r      2   | 1/8 r 3 r 2 r 3          |        
### ... adoramus (m. 16)
1:     d'2 r2  ab  | c'2 b4      | c'3  _bag   | f6          |
2:     a2  d2  a2  | rg  g^f2e   | g4       r2 | a_b c'2 a2  | 
3:     d2  f2  r2  | cc  d2  d2  | c5        r | f,2 f,2 f,2 |
4: 1/8 0 r 0 r r r | 0 r r 1 r 1 | 0 r r 1 r r | 0 r 1 r r 0 |
5:     r 2 r 2 r 2 | r 2 r 2 r 2 | r 2 r 2 r 3 | r 2 r 2 r 3 |
###                             
1: e2f e2d | f5            r |
2: b4   b2 | c'2 r2 r2       |
3: g,4 g,2 | f,5           r | 
4: 0 r r 1 r r | 0 r r 1 1 1 |
5: r 2 r 2 r 3 | r 2 r 2 r 2 |
###  Gratias agimus tibi:
1: r6          | a2  f2              g2  | a3    b ga  | b2  rc'  ab |
2: c'2 g2  b2  | c'3               d'bc' | d'2 c'2 rc' | d'b a2  r^f |
3: f2  gf  ed  | c2  f2              e2  | rd   f2 e2  | d6          |
4: 0 r r 1 r r | 0 r r 1/16 1 1 1/8  0 r | 0 r r 1 1 1 | 0 r 1 r 0 r |
5: r 2 r 2 r 2 | r 3 r      2        r 3 | r 2 r 2 r 2 | r 2 r 2 r 3 |
###
1: c'2 rd' bc' | e'd'2  c'2b | c'6                || 
2: ga  g2  a2  | rba    g2^f | g6                 || 
3: rc  e2  d2  | f2 e2   d2  | c5             r   || 
4: 0 r 0 r 1 r | 0 r r 1 1 1 | 0 r r 1 r 1/16 0 0 ||
5: r 2 r 2 r 3 | r 2 r 2 r 2 | r 3 r 2 r      3   ||  
### Domine deus:
1:     r6     | c'3 _ba2 | g2  f  e2d  | f5        r | 
2:     r6     | r6       | d'3 c'  b2  | c'2 a3    r |
3:     f3 ed2 | c6       | g,6         | f,5       r |
4: 1/8 0 r5   | 0 r5     | 0 r5        | 0 r4      1 |
5: 1/8 r6     | r6       | r r 3 r r r | r r r 2 2 2 | 
###
1: a2 b2  c'2  | d'2c'   b2a | b6          | r4      bc' |
2: f2 g2  g2   | a2  r2  bc' | d'2   b4    | r6          |
3: f2 e4       | d6          | g,2  r2  ef | g2  e4      |
4: 0 r r 1 r r | 0 r r 1 1 1 | 0 r r 1 1 r | 0 r r 1 r r |
5: r 2 r 2 r 3 | r 2 r 2 r 2 | r 2 r 2 r 3 | r 3 r 2 3 2 |
### omnipotens
1: d'2  b4            |      ab c'      b2a    |     c'6                    |
2: r6                 |      a2    g2    ^f2   |     g6                     |
3: d6                 |      f2    e2    d2    |     c6                     |
4: 0 r r 1 1      1   | 1/12 0 1 r 0 1 r 0 1 r | 1/8 0      r       r 1 1 0 |
5: r 2 r 2 r 1/16 3 2 | 1/12 r2  2 r2  2 r2  3 | 1/8 r 1/16 3 2 1/8 2 r r 2 |
### Domine Fili
1: r6          | c'3  _ba2    | g2f   e2d   | f4   r2     |
2: r6          | r6           | d'3 c' b2   | c'2 a4      |
3: f3 ed2      | c6           | g,6         | f,6         |
4: 0 r 0 r 0 r | 0 r 0 r 0 r  | 0 r 0 r 0 r | 0 r2 1/24 @7 1 
4:                                             @< 1 1 1 1 1 1/8 @8 1 |
5: 1/8 r6      | r6           | r 2 r 3 r 2 | r 2 r 2 r 3 |                       
### unigenite 
1: g2a   f2g   | a2  "6%0.01%0%1%0.1" _ba_bg |
2: g2f   e2d   | e2  "6%0.01%0%1%0.1" g4     |
3: c2    d4    | c2_b, a,g,2                 | "6%0.01%0%1%0.1"
4: 0 r r 0 1 r | 0 r 0 r3                    |
5: r 2 r 3 r 2 | r 3 2 r3                    |
###  tail of <<JESU CHRISTE>>
1:      a6       | c'6     |      d'5          r  |     r
2:      f6       | g6      |      a5           r  |     r
3:      d6       | _e4 _e2 |      d5           r  |     r                  
4: 1/8  0 r5     | 0 r5    | 3/32 0 r3    1 1 r2  | 1/8 r
5: 1/24 r @55 2 @< 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 | 2 2 2 2 2 2 2 2 2 
5:                                                   2 2 2 2 2 2 2 2 @7 2 | 
5:                                                   3/32 r 2 2 2 r 2 3 2 | 
5:                                                   1/8 r 
### Domine Deus (Agnus Dei) (bar 50)
1: "3%0.01%0%1%0.2"   
2: "4%0.01%0%1%0.2"           
3: "2%0.01%0%1%0.2"           
1:     r6          | c'3  _ba2   | g2f   e2d   | f4     r2   |
2:     r6          | r6          | d'3   c'b2  | c'2 a4      |
3:     f3    ed2   | c6          | g,6         | f,6         |
4: 1/8 0 r r 1 r r | 0 r r 1 1 1 | 0 r r 1 1 r | 0 r r 1 r r |
5: 1/8 r 2 r 2 r 3 | r 2 r 2 r 2 | r 2 r 2 r 2 | r 2 r 2 r 3 |
### Agnus Dei:
1: g2a _b2a    | g2a   _b2r  | c'3d' _bc'  | d'6                |
2: g2e  f2g    | e3     f2f  | g2 ag fg    | a4      r2         |
3: c2c _b,2_b, | c2c   _b,3  | _e6         | d6                 |
4: 0 r r 1 r r | 0 r r 1 1 1 | 0 r r 1 1 r | 0 r r 1 r 1/16 1 1 |
5: r 2 r 2 r 3 | r 2 r 2 r 2 | r 2 r 2 r 3 | r 3 2 2 r      2   |
### Qui Tollis:
1:     r6          | c'2 d'c'_bc' | a_bg f2  e  | f4 r2       |
2:     a2 g2 f2    | g2  a2  g2   | fed  c2  b, | c6          |
3:     f2 gf ed    | c6           | f,2 g,4     | f,6         |
4: 1/8 0 r r 1 r r | 0 r r 1 1 1  | 0 r r 1 1 r | 0 r 1 r r r |
5:     r 2 r 2 r 2 | r 2 r 2 r 2  | r 2 r 2 r 2 | r 3 2 r r r |
### Misere (softer, timbre change)
1: "5%0.01%0%1%0.2" @68 mix=1.2
2: "5%0.01%0%1%0.2" @68 mix=1.2
3: "5%0.01%0%1%0.2" @68 mix=1.2
1:     c'2 d'4     | c'4    _b2  | a_ba  g2^f  | g6          |
2:     f2  a4      | g4      f2  | e3    d2^c  | d4 r2       |
3:     f4      f2  | e2 d4       | c2 _b,2 a,2 | g,6         |
4: @67 0 r r r r r | 0 r r r r r | 0 r 0 r r r | 0 r 0 r r r |  
5: @60 r 2 2 2 2 2 | r 2 2 2 2 2 | r 2 r 2 2 2 | r 2 r 2 2 3 |
### Qui Tollis II (m. 65)
1:    r6                     | @<  c'2 d'c' _ba |  g2f   e2d   | f6          | 
2: @< c2 d2   e2             |     fg  a2   c'2 | _bc'd' c'2b  | c'6         |
3: @< c2 _b,a, _b,g,         |     f,6          |  c2  g,4     | f,6         |
4: @< 0 r r 1/16 1 1 1/8 1 r | 1/8 0 r r 1 1 1  |  0 r r 1 1 r | 0 r r 1 r 0 |
5: @< r 2 r      2       r 2 |     r 2 r 3 r 2  |  r 2 r 2 r 2 | r 3 2 2 r 2 |
### Suscipe (m. 69)
1:    r6     | @< c'3 _ba2 |    g2 d2  e2   | f2  ef   g2     | 
2:    r6     |    r6       | @< d'3 c' b2   | rc'_b    a2 _b  |
3: @< f3 ed2 |    c6       |    g,6         | f,g, a,2   g,a, |  
4:    0 r5   |    0 r5     |    0 r5        | 0 r2  1/24 @67 1 @< 1 1 1 1 1 
4:                                             1/8 @75 1 |
5:    r6     |    r6       |    r 2 r 2 r 3 | r 2  r  2  r 2 |
### m. 73:
1:      fga    _bag  | t=147 _bag   f2e | t=140 @79 f5  r r t=140 || t=150
2:      ag2    a_bc' |       d'c'2 _b2a |       @79 c'5 r r       ||
3:     _b,2 a,_b,c2  |       f,2 g,4    |       @79 f,5 r r       ||
4: 3/16 0  r  1  r   |       0  r  1  r |      1/8  0 r6          ||
5: 3/16 r  2  r  2   |     r  3  r @7 2 |      1/8  r r6          ||
#################################################
## Qui sedes (m. 76) drums dropout??? echo??? :##
#################################################
1: "4%0.01%0%1%0.2" @72 mix=1.25
2: "4%0.01%0%1%0.2" @72 mix=1.17
3: "4%0.01%0%1%0.2" @72 mix=1.0
1: (c'4 a2 | _b6    | c'3 a_bc' | d'5)  r | (d'e'd'c'2b | c'3)   rga |
2: (a4  ag |  f5) r | r(g2 f2e  | f5)   r | r(a g2 ^f2  | g5)      r |  
3: (f2  c4 |  d5) r | (c2 d2 c2 | _b,5) r | (f2 e2 d2   | c4) r2     | 
4: r36
5: r36 
### misere nobis (m. 82):
1: _b3 r   (a_b | c'_ba g2^f  | g5)   r |
2: r2   (de f2  | gfe   d2^c  | d4)  r2 |
3: (_b,c d2 d2  | c2 _b,2 a,2 | g,5)  r |
4: r18
5: r18 
### Quonium tu solis:
1: r6              | f2 fe fd    | c2 b,4   | c5        r           |
2: c2  de    fe    | f2 r2 r2    | gab c'2b | c'2 c'_b ag           |
3: c2 _b,a, _b,g,  | f,6         | c2 d4    | c5        r           |
4: @7 0 r r r r r  | 0 r 0 r 1 r | 0 r5     | 0 r 0 r 1 r           | 
5: @6 3/16 r 2 r 2 | r 2   r 3   | r  2 r 2 | r 2 r 3/64 3 3 3/32 2 |
### bass 'Tu so-lus'
1:     r6          | c'2 d'c'_ba | g2  r4      | d'd' e'd'          c'b |
2:     f2  r4      | g2  e2   f2 | g2  d2  c2  | d2  f2             e2  | 
3:     f2  gf  ed  | c2  r4      | gg  ag  fe  | d2  r4                 |
4: 1/8 0 r 0 r r r | 0 r r 1 r r | 0 r 0 r r r | 0 r r 1/16 1 1 1/8 r 1 |
5: 1/8 r 2 r 2 r 2 | r 2 r 2 r 3 | r 2 r 2 r 2 | r 2 r      2       r 3 |
###
1: ar b2   c'2 | d'2c' b2a   | b5                 r      | 
2: d4      e2  | ^fga g2^f   | g5                 r      |
3: f4      e2  | d6          | g,5                r      |
4: 0 r 0 r 1 r | 0 r r 1 r 0 | 1/8 0 r 0 r r 1/24 1 1 1  |
5: r 2 r 2 r 2 | r 2 r 2 r 2 | 1/8 r 3 r 2 r      3      |
### Cum sancto spiritu
1: "6%0.01%0%1%0.2" mix=1.2
2: "6%0.01%0%1%0.2" mix=1.2
3: "6%0.01%0%1%0.2" mix=1.2
1: @72 a2 @< b c'2c'     | a2b   c'2d' |      b2c' d'2e' | 
2: @72 f2 @< f g2g       | f2f   g2a   |      g2g  a2b   |
3: @72 d2 @< d c2c       | d2d   c2c   |      e2e  d2d   |
4: @8 1/8 0 r @< 1 0 r 1 | 0 r 1 0 r 1 | 3/16 0  r  1  0 |
5: @7 1/8 r 3 r r @< 2 r | r 3 r r 2 r | 3/16 r  2  r  3 |
### Dei patris
1:     d'e'd'       c'2b      |     c'_ba  g2f  |
2:     a2   g2       ^f2      |     g2  r2 a2   |
3:     f2   e2       d2       |     c6          |
4: 1/8 0 r r 1/16 1 1 1/8 1 r | 1/8 0 r r 1 1 1 |
5: 1/8 r 2 r      2       r 2 |     r 2 r 3 r 2 |
###
1: t=147 e6                               | t=130 @78 f5         r r r t=130 ||
2:       b6                               | @78       c'5          r r r     ||
3:       g,6                              | @78       f,5          r r r     ||
4: 1/16  0 3 1 0 2 1 0 3 [0 1] r [0 1] r  | 1/8       0 r @8 0 r r r r r     ||
5: 1/16  r8               3    r  3    r  | 1/8       r 3 @7 2 r r r r r     ||
##### extra layer CUM SANCTO:
1: &-44 "2%0.01%0%1%0.2" mix=0.65
2: &-44 "2%0.01%0%1%0.2" mix=0.65
3: &-44 "2%0.01%0%1%0.2" mix=0.65
1: @72 a2 @< b c'2c' | a2b c'2d' | b2c' d'2e' |
2: @72 f2 @< f g2g   | f2f g2a   | g2g  a2b   |
3: @72 d2 @< d c2c   | d2d c2c   | e2e  d2d   |
1: d'e'd' c'2b | c'_ba g2f | e6  | @78 f5  r r r ||
2: a2  g2  ^f2 | g2 r2 a2  | b6  | @78 c'5 r r r ||
3: f2  e2  d2  | c6        | g,6 | @78 f,5 r r r ||
##########
## AMEN ##
##########
1: "3%0.01%0%1%0.2"  t=147 mix=1.2
2: "4%0.01%0%1%0.2"        mix=1.5
3: "2%0.01%0%1%0.2"        mix=1.4
1:     @73 (c'4 @< a_b    | c'3 d'_bc'  |    a2) r2 (b2  | c'3 bc'a    |
2:     @76 (f3 @<  efd    | c6          |    d2 e2 f2)   | r(g a2 g2)  | 
3:     @74 f,6-           | f,6         | @< (f3  efd    | c2) r2 (c2  |
4: 1/8 @81 0 r @< 1 r r 0 | 0 r 0 r 1 r |    0 r 1 r r 0 | 0 r 0 r 1 r | 
5: 1/8 @74 r 2 r @< 3 2 r | r 2 r 3 r 2 |    r 2 r 3 2 r | r 2 r 3 r 2 |
###
1:  g2) r2 (c'2 | d'3 c'd'_b  | a2) r2 (_b2 |      c'_bc'   a2g      |
2:  r(c d2 g2)  | r(a _b2 a2) | r(d e2  f2  |      ga   fa   ga      |
3:  g3     fge  | d2) r2 (d2  | f3     efd  |      c2   f,2  c2)     |
4:  0 r 1 r r 0 | 0 r 1 r r 0 | 0 r 0 r 1 r | 1/12 0 1 r 0 1 r 0 1 r |
5:  r 2 r 3 2 r | r 2 r 3 2 r | r 2 r 3 r 2 | 1/12 r2  2 r2  2 r2  2 |
### m. 111:
1:      af   e2)      r(f  |     ga    f2) r(g            | af g2) r(a  |
2:      f2)   rg      ab   |     c'2   rc' ga             | b2  r(c'bc' |
3:      r(f,  c2      d2)  |     r(c   f,2 c2)            | r(d c2 e2   |
4:  1/8 0 r 1 r r 1/16 0 0 | 1/8 0 r 0 1/24 1 1 1 1/8 1 r | 0 r 1 r r 0 |
5:  1/8 r 2 r 3 2      1   |     r 2 r      3         r 2 | r 2 r 3 2 r |
### approaching end, extra '1:' voice for tempo control
1: r16                                       t=147  r19 t=107 r12 &-47
1: _bc' ad' c'd'             | a2) r4             |    (c'2 d'c'_ba |
2: d'2 e'd'c'_b              | a2  g2  f2)        |     r(g e2   f2 |
3: d6                        | f2  gf  ed         |     c2) r2  (f2 |
4: 0 r 0 1/24 1 1 1 1/8  1 r | 0 r 1 r r 1/16 0 0 | 1/8 0 r 0 r 1 r |
5: r 2 r 3 r 2               | r 2 r 3 2      r   |     r 2 r 3 r 2 |      
###
1: g2) r2 (a2      | b6)   r                                        |
2: gfe    d2c      | d2 e4) r                                       |
3: c3    _b,ca,    | g,6)   r                                       |
4: 0 r 1 r     r 0 | 0 r 1/32 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1/8 r |
5: r 2 r 3 @82 2 r | r7                                             | 
### LAST NOTE!
1:     @78  c'12       ||
2:     @82  f12        ||
3:     @82  f,12       ||
4: 1/8 @83 [0 1 3] r11 ||
5:         r12         ||
### extra layer for AMEN:
1: &-109 i=1.4 "2%0.01%0%1%0.2" @6  mix=1.0
2: &-109 i=1.5 "2%0.01%0%1%0.2" @62  mix=1.1
3: &-109 i=1.6 "2%0.01%0%1%0.2" @62 mix=1.3
1:   (c'4 @< a_b    | c'3 d'_bc'  |    a2) r2 (b2  | c'3 bc'a    |
2:   (f3 @<  efd    | c6          |    d2 e2 f2)   | r(g a2 g2)  | 
3:    f,6-           | f,6         | @< (f3  efd    | c2) r2 (c2  |
###
1:  g2) r2 (c'2 | d'3 c'd'_b  | a2) r2 (_b2 |      c'_bc'   a2g      |
2:  r(c d2 g2)  | r(a _b2 a2) | r(d e2  f2  |      ga   fa   ga      |
3:  g3     fge  | d2) r2 (d2  | f3     efd  |      c2   f,2  c2)     |
### m. 111:
1:      af   e2)      r(f  |     ga    f2) r(g            | af g2) r(a  |
2:      f2)   rg      ab   |     c'2   rc' ga             | b2  r(c'bc' |
3:      r(f,  c2      d2)  |     r(c   f,2 c2)            | r(d c2 e2   |
###
1: _bc' ad' c'd'             | a2) r4             |    (c'2 d'c'_ba |
2: d'2 e'd'c'_b              | a2  g2  f2)        |     r(g e2   f2 |
3: d6                        | f2  gf  ed         |     c2) r2  (f2 |
###
1: g2) r2 (a2      | b6)   r                                        |
2: gfe    d2c      | d2 e4) r                                       |
3: c3    _b,ca,    | g,6)   r                                       |
### LAST NOTE of EXTRA LAYER!
1:     @65  c'12        ||
2:     @67  f12         ||
3:     @63  f,12        ||
### Allow for reverb tail: 
1: r9 mix=0.01 @0 r 
2: r9 mix=0.01 @0 r
3: r9 mix=0.01 @0 r
4: r9 mix=0.01 @0 0
5: r9 mix=0.01 @0 0
### END OF FILE
