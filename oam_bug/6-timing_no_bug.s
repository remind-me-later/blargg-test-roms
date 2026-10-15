; Verifies no corruption when done at "safe" times

DEF TEST_NAME EQUS "6-timing_no_bug"
INCLUDE "oam_bug.inc"

Main:
     call DisableLCD
     call FillOAM

     call Test

     call DisableLCD
     call CpOAM

     call PrintOAM
     check_crc $7BB4F198
     jp   TestsPassed

Test:
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
.visibleLine:
     inc  de
     delay 18
     dec  de
     delay 114-22-4
     dec  b
     jr   nz,.visibleLine

     ; Try to trigger constantly during vblank
     ld   b,10
     jr   .vblankEnter
.vblankLine:
     delay 13
.vblankEnter:
     ld   c,12
.vblankInner:
     inc  de
     dec  c
     dec  de
     jr   nz,.vblankInner
     dec  b
     jr   nz,.vblankLine

     delay 4

     dec  h
     jr   nz,.loop

     ret

INCLUDE "shell_end.inc"
