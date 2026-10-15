; Finds highest and lowest frequencies that don't overflow
; immediately on trigger, for NR10 values of $00-$07

DEF TEST_NAME EQUS "06-overflow on trigger"
INCLUDE "shell.inc"
INCLUDE "apu.s"

Main:

     ; DMG-06:
     ; 0555 0666 071C 0787 07C1 07E0 07F0

     wreg rAUD1ENV,8
     ld   d,$01
ShiftLoop:
     ld   a,d
     sta  rAUD1SWEEP
     ld   bc,$87FF
.searchDown:
     ld   a,c
     sta  rAUD1LOW
     ld   a,b
     sta  rAUD1HIGH
     delay_clocks 40
     lda  rAUDENA
     and  1
     jr   nz,.foundDown
     dec  bc
     bit  6,b
     jr   z,.searchDown
.foundDown:
     res  7,b
     call PrintBC
     inc  d
     bit  3,d
     jr   z,ShiftLoop
     call PrintNewline
     check_crc $F604603B

     ; DMG-05, DMG-06, DMG-09,  CGB-04, CGB-05:
     ; 0556 0667 071D 0788 07C2 07E1 07F1

     wreg rAUD1ENV,8
     ld   d,$01
ShiftLoop2:
     ld   a,d
     sta  rAUD1SWEEP
     ld   bc,$8000
.searchUp:
     ld   a,c
     sta  rAUD1LOW
     ld   a,b
     sta  rAUD1HIGH
     delay_clocks 40
     lda  rAUDENA
     and  1
     jr   z,.foundUp
     inc  bc
     bit  6,b
     jr   z,.searchUp
.foundUp:
     res  7,b
     call PrintBC
     inc  d
     bit  3,d
     jr   z,ShiftLoop2
     check_crc $5A1697EE

     jp   TestsPassed

INCLUDE "shell_end.inc"
