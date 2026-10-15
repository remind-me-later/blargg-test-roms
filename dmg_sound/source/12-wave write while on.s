; Writes to wave RAM while playing

DEF REQUIRE_DMG = 1
;DEF REQUIRE_CGB = 1
DEF TEST_NAME EQUS "12-wave write while on"
INCLUDE "shell.inc"
INCLUDE "apu.s"

main:
     loop_n_times test,69

     ; CGB behaves erratically, so DMG-only for now
     check_crc_dmg_cgb $3B4538A9,$2B27544E
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

     ; Write to wave
     wreg rAUD3LOW,-2   ; period = 4
     delay_clocks 168
     wreg rAUD3WAVE_0,$F7

     ; Print wave RAM
     wreg rAUD3ENA,0
     delay 1000
     ld   hl,AUD3WAVERAM
:    ld   a,[hli]
     call print_a
     bit  6,l
     jr   z,:-
     call print_newline

     ret

wave:
     db $00, $11, $22, $33, $44, $55, $66, $77
     db $88, $99, $AA, $BB, $CC, $DD, $EE, $FF

INCLUDE "shell_end.inc"
