; Verifies LCD timing when turning on. Necessary for
; timing tests to work right.

; With LCD off, turning it on synchronizes to beginning
; of first visible scanline

DEF TEST_NAME EQUS "1-lcd_sync"
INCLUDE "oam_bug.inc"

Main:
     set_test 2,"Turning LCD on starts too late in scanline"
     call DisableLCD
     ld   a,$81
     ldh  [rLCDC],a ; LCD on
     delay 109
     ldh  a,[rLY]   ; just before LY increments
     cp   0
     jp   nz,TestFailed

     set_test 3,"Turning LCD on starts too early in scanline"
     call DisableLCD
     ld   a,$81
     ldh  [rLCDC],a ; LCD on
     delay 110
     ldh  a,[rLY]   ; just after LY increments
     cp   1
     jp   nz,TestFailed

     jp   TestsPassed

INCLUDE "shell_end.inc"
