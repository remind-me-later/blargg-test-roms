; Finds highest and lowest frequencies that don't overflow
; immediately on trigger, for NR10 values of $00-$07

DEF TEST_NAME EQUS "06-overflow on trigger"
INCLUDE "shell.inc"
INCLUDE "apu.s"

main:

     ; DMG-06:
     ; 0555 0666 071C 0787 07C1 07E0 07F0

     wreg rAUD1ENV,8
     ld   d,$01
shift_loop:
     ld   a,d
     sta  rAUD1SWEEP
     ld   bc,$87FF
:    ld   a,c
     sta  rAUD1LOW
     ld   a,b
     sta  rAUD1HIGH
     delay_clocks 40
     lda  rAUDENA
     and  1
     jr   nz,:+
     dec  bc
     bit  6,b
     jr   z,:-
:    res  7,b
     call print_bc
     inc  d
     bit  3,d
     jr   z,shift_loop
     call print_newline
     check_crc $F604603B

     ; DMG-05, DMG-06, DMG-09,  CGB-04, CGB-05:
     ; 0556 0667 071D 0788 07C2 07E1 07F1

     wreg rAUD1ENV,8
     ld   d,$01
shift_loop2:
     ld   a,d
     sta  rAUD1SWEEP
     ld   bc,$8000
:    ld   a,c
     sta  rAUD1LOW
     ld   a,b
     sta  rAUD1HIGH
     delay_clocks 40
     lda  rAUDENA
     and  1
     jr   z,:+
     inc  bc
     bit  6,b
     jr   z,:-
:    res  7,b
     call print_bc
     inc  d
     bit  3,d
     jr   z,shift_loop2
     check_crc $5A1697EE

     jp   tests_passed

INCLUDE "shell_end.inc"
