; Verifies no corruption when done at "safe" times

DEF TEST_NAME EQUS "6-timing_no_bug"
INCLUDE "oam_bug.inc"

main:
     call disable_lcd
     call fill_oam

     call test

     call disable_lcd
     call cp_oam

     call print_oam
     check_crc $7BB4F198
     jp   tests_passed

test:
     ld   de,$FE00
     wreg rLCDC,LCDC_ON | LCDC_BG_ON

     ; Have first INC DE at scanline 0 beginning
     delay 70224 - 7

     ; Run for several frames
     ld   h,10
.loop:

     ; Try to trigger just before and just after
     ; window where corruption occurs, for every
     ; scanline
     ld   b,144
.visible_line:
     inc  de
     delay 18
     dec  de
     delay 114-22-4
     dec  b
     jr   nz,.visible_line

     ; Try to trigger constantly during vblank
     ld   b,10
     jr   .vblank_enter
.vblank_line:
     delay 13
.vblank_enter:
     ld   c,12
.vblank_inner:
     inc  de
     dec  c
     dec  de
     jr   nz,.vblank_inner
     dec  b
     jr   nz,.vblank_line

     delay 4

     dec  h
     jr   nz,.loop

     ret

INCLUDE "shell_end.inc"
