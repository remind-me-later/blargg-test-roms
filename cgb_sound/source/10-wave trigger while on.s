; Retriggers wave without stopping first

;DEF REQUIRE_DMG = 1
;DEF REQUIRE_CGB = 1
DEF TEST_NAME EQUS "\"10-wave trigger while on\""
INCLUDE "shell.inc"
INCLUDE "apu.s"

main:
     wreg rAUDTERM,0    ; mute sound
     loop_n_times test,69
     check_crc_dmg_cgb $533D6D4D,$8130733A
     jp   tests_passed

test:
     add  $99
     ld   b,a

     ; Reload wave and have its first
     ; sample read occur 2 clocks earlier
     ; each loop iteration
     ld   hl,wave
     call load_wave
     wreg rAUD3ENA,$80  ; enable
     wreg rAUD3LEVEL,$00  ; silent
     ld   a,b
     sta  rAUD3LOW      ; period
     wreg rAUD3HIGH,$87  ; start

     ; Retrigger wave
     wreg rAUD3LOW,-2   ; period = 4
     delay_clocks 168
     wreg rAUD3HIGH,$87  ; restart
     delay_clocks 40

     ; Print wave RAM
     wreg rAUD3ENA,0
     ld   c,$30
:    ld   a,[$FF00+c]
     call print_a
     inc  c
     bit  6,c
     jr   z,:-
     call print_newline

     ret

wave:
     db $00, $11, $22, $33, $44, $55, $66, $77
     db $88, $99, $AA, $BB, $CC, $DD, $EE, $FF

INCLUDE "shell_end.inc"
