; Tests wave channel timer reload and phase rest on trigger,
; and access to wave RAM while playing.
DEF REQUIRE_CGB = 1
DEF TEST_NAME EQUS "12-wave"
INCLUDE "shell.inc"
INCLUDE "apu.s"

main:
     ld   hl,wave
     call load_wave
     wreg rAUD3LEVEL,0

     set_test 2,"Timer period or phase resetting is wrong"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     delay_clocks 1024
     wreg rAUD3HIGH,$80
     ld   c,$31
     ld   de,-$FE
     call test_wave

     set_test 3,"Current byte readable at any wave addr"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     ld   c,$3C
     ld   de,-$FE
     call test_wave

     set_test 5,"Normal access when chan disabled"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     wreg rAUD3ENA,$00  ; disable chan
     wreg rAUD3ENA,$80  ; DAC on
     ld   c,$31
     ld   de,0
     call test_wave

     set_test 6,"Write test"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$F0
     wreg rAUD3HIGH,$87
     delay_clocks 256
     wreg $FF30,$BC
     wreg rAUD3ENA,0
     ld   a,[$FF34]
     cp   $BC
     jp   nz,test_failed

     set_test 7,"Timer period change"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$87
     wreg rAUD3LOW,$F0
     ld   c,$30
     ld   de,-$E
     call test_wave

     set_test 8,"Frequency 0 is valid"
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$80
     ld   c,$30
     ld   de,-$FE
     call test_wave

     set_test 9,"Maintains phase properly when vol = 0"
     wreg rAUD3ENA,$80
     wreg rAUD3LEVEL,0
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$87
     ld   c,$30
     ld   de,-$1E
     call test_wave

     set_test 10,"Maintains phase properly when stereo = 0"
     wreg rAUDTERM,$00
     wreg rAUD3ENA,$80
     wreg rAUD3LOW,$00
     wreg rAUD3HIGH,$87
     ld   c,$30
     ld   de,-$1E
     call test_wave

     jp   tests_passed

test_wave:
:    inc  de             ; 8
     ld   a,[$FF00+c]    ; 8
     or   a              ; 4
     jr   z,:-            ; 12

     ;call     print_a
     ;call     print_de

     cp   $11
     jp   nz,test_failed


     ; Error if not in 0...4 range
     ld   a,d
     cp   0
     jp   nz,test_failed
     ld   a,e
     cp   5
     jp   nc,test_failed
     ret

wave:
     db $00, $11, $22, $33, $44, $55, $66, $77
     db $88, $99, $AA, $BB, $CC, $DD, $EE, $FF

INCLUDE "shell_end.inc"
