; After powering sound off then on, NR12, NR14, and NR44
; are clear.
DEF TEST_NAME EQUS "11-regs after power"
INCLUDE "shell.inc"
INCLUDE "apu.s"

main:
     call sync_apu

     ld   a,$FF
     call fill_apu_regs

     ; Power down for a moment
     wreg rAUDENA,AUDENA_OFF
     wreg rAUD4LEN,-$12
     wreg rAUD1ENV,$F0
     delay_msec 100
     wreg rAUDENA,AUDENA_ON

     set_test 2,"Powering off should clear NR12"
     call sync_apu
     wreg rAUD1HIGH,$80
     lda  rAUDENA
     and  $01
     jp   nz,test_failed

     set_test 3,"Powering off should clear NR13"
     call sync_apu
     wreg rAUD1SWEEP,$11
     wreg rAUD1ENV,$08
     wreg rAUD1HIGH,$80
     delay_apu 20
     lda  rAUDENA
     and  $01
     jp   z,test_failed

     set_test 4,"Powering off should clear NR41"
     call sync_apu
     delay_clocks 8192 ; avoids extra length clocking
     wreg rAUD4ENV,$08
     wreg rAUD4GO,$C0
     delay_apu 63
     lda  rAUDENA
     and  $08
     jp   z,test_failed
     delay_apu 1
     lda  rAUDENA
     and  $08
     jp   nz,test_failed

     jp   tests_passed

INCLUDE "shell_end.inc"
