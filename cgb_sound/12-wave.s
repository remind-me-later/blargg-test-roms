; Tests wave channel timer reload and phase rest on trigger,
; and access to wave RAM while playing.
DEF TEST_NAME EQUS "12-wave"
INCLUDE "shell.inc"
INCLUDE "apu.s"

Main:
     ld   hl,Wave
     call LoadWave
     wreg rAUD3LEVEL,0

     set_test 2,"Timer period or phase resetting is wrong"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     delay_clocks 1024
     wreg rAUD3HIGH,$80
     ld   c,$31
     ld   de,-$FE
     call TestWave

     set_test 3,"Current byte readable at any wave addr"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     ld   c,$3C
     ld   de,-$FE
     call TestWave

     set_test 5,"Normal access when chan disabled"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     wreg rAUD3ENA,$00  ; disable chan
     wreg rAUD3ENA,$80  ; DAC on
     ld   c,$31
     ld   de,0
     call TestWave

     set_test 6,"Write test"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$F0
     wreg rAUD3HIGH,$87
     delay_clocks 256
     wreg $FF30,$BC
     wreg rAUD3ENA,0
     ld   a,[$FF34]
     cp   $BC
     jp   nz,TestFailed

     set_test 7,"Timer period change"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$87
     wreg rAUD3LOW,$F0
     ld   c,$30
     ld   de,-$E
     call TestWave

     set_test 8,"Frequency 0 is valid"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     ld   c,$30
     ld   de,-$FE
     call TestWave

     set_test 9,"Maintains phase properly when vol = 0"
     wreg rAUD3ENA,$80
     wreg rAUD3LEVEL,0
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$87
     ld   c,$30
     ld   de,-$1E
     call TestWave

     set_test 10,"Maintains phase properly when stereo = 0"
     wreg rAUDTERM,$00
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$87
     ld   c,$30
     ld   de,-$1E
     call TestWave

     jp   TestsPassed

TestWave:
.wait:
     inc  de             ; 8
     ld   a,[$FF00+c]    ; 8
     or   a              ; 4
     jr   z,.wait         ; 12

     ;call     PrintA
     ;call     PrintDE

     cp   $11
     jp   nz,TestFailed


     ; Error if not in 0...4 range
     ld   a,d
     cp   0
     jp   nz,TestFailed
     ld   a,e
     cp   5
     jp   nc,TestFailed
     ret

Wave:
     db $00, $11, $22, $33, $44, $55, $66, $77
     db $88, $99, $AA, $BB, $CC, $DD, $EE, $FF

INCLUDE "shell_end.inc"
