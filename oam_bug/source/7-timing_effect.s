; Verifies corruption for each timing

DEF TEST_NAME EQUS "\"7-timing_effect\""
INCLUDE "oam_bug.inc"

main:
     loop_n_times test,116
     check_crc $7D792E7C
     jp   tests_passed

test:
     inc  a
     ld   b,a
     push bc
     call disable_lcd
     call fill_oam
     call corrupt_oam
     call disable_lcd
     call cp_oam
     pop  bc

     jr   z,:+
     call print_b
     call print_newline
     call print_oam
     call print_newline

:    ret

corrupt_oam:
     wreg rLCDC,LCDC_ON | LCDC_BG_ON
     ld   a,b
     call delay_a_20_cycles
     delay 86

     ld   de,$FE00
     inc  de

     ret

INCLUDE "shell_end.inc"
