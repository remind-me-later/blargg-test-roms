; Calc = calculation of new frequency and check for > $7FF
; Update = modification of frequency with new calculated value
DEF TEST_NAME EQUS "05-sweep details"
INCLUDE "shell.inc"
INCLUDE "apu.s"

Begin:
     call SyncSweep
     wreg rAUD1HIGH,$40
     wreg rAUD1LEN,-$20
     wreg rAUD1ENV,$08
     ret

ShouldBeAlmostOff:
     lda  rAUDENA
     and  $01
     jp   z,TestFailed
     delay_apu 1
ShouldBeOff:
     lda  rAUDENA
     and  $01
     jp   nz,TestFailed
     ret

Main:
     set_test 2,"Timer treats period 0 as 8"
     call Begin
     wreg rAUD1SWEEP,$11
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$C2
     delay_apu 1
     wreg rAUD1SWEEP,$01  ; sweep enabled
     delay_apu 3
     wreg rAUD1SWEEP,$11  ; non-zero period so calc will occur when timer reloads
     delay_apu $11
     call ShouldBeAlmostOff

     set_test 3,"Makes private copy of frequency on trigger"
     call Begin
     wreg rAUD1SWEEP,$12
     wreg rAUD1LOW,$04
     wreg rAUD1HIGH,$80
     wreg rAUD1LOW,$00
     delay_apu $39
     call ShouldBeAlmostOff

     set_test 4,"Exiting negate mode after calculation disables channel"
     call Begin
     wreg rAUD1SWEEP,$09  ; since shift > 0, calculates sweep value at init
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$C0
     delay_apu 2
     wreg rAUD1SWEEP,$10  ; neg->pos, so disables channel
     call ShouldBeOff

     set_test 5,"Ending negate after it maybe changed freq disables chan"
     call Begin
     wreg rAUD1SWEEP,$10  ; enable sweep
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$C0
     delay_apu 2
     wreg rAUD1SWEEP,$18  ; negate mode
     delay_apu 2
     wreg rAUD1SWEEP,$10  ; neg->pos, so disables channel
     call ShouldBeOff

     set_test 6,"Ending negate mode any other way doesn't disable channel"
     call Begin
     wreg rAUD1SWEEP,$1F  ; use negate mode once
     wreg rAUD1HIGH,$C0
     delay_apu 2
     wreg rAUD1SWEEP,$18  ; since period > 0, doesn't calculate at init
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$C0
     delay_apu 1    ; no sweep clock here
     wreg rAUD1SWEEP,$10  ; pos mode before neg mode ever used
     delay_apu 1    ; sweep clock occurs here
     wreg rAUD1SWEEP,$0F  ; now let neg mode be seen once, but period = 0 so no calculation is made
     delay_apu 2    ; sweep clock occurs here
     wreg rAUD1SWEEP,$10  ; doesn't affect channel
     delay_apu 2    ; sweep clock occurs here
     wreg rAUD1SWEEP,$1F  ; let neg mode get used
     delay_apu 18
     wreg rAUD1SWEEP,$79  ; period and shift can be changed without channel disabling
     delay_apu 5
     call ShouldBeAlmostOff

     set_test 7,"Subtract mode uses two's complement"
     call Begin
     delay 2048      ; avoids extra length clocking on CGB-02
     wreg rAUD1SWEEP,$1C
     wreg rAUD1LOW,$B0
     wreg rAUD1HIGH,$85
     delay_apu 2
     wreg rAUD1SWEEP,$01
     wreg rAUD1HIGH,$C5
     delay_apu $1F
     call ShouldBeAlmostOff

     set_test 8,"Subtract mode uses two's complement (upper bound)"
     call Begin
     wreg rAUD1SWEEP,$1C
     wreg rAUD1LOW,$B1
     wreg rAUD1HIGH,$85
     delay_apu 2
     wreg rAUD1SWEEP,$01
     wreg rAUD1HIGH,$C5
     call ShouldBeOff

     set_test 9,"Update channel frequency only when period is reloaded"
     call Begin
     wreg rAUD1SWEEP,$74
     wreg rAUD1LOW,$06
     wreg rAUD1HIGH,$85
     delay_apu 14 ; just reloaded
     wreg rAUD1LOW,$06
     delay_apu 13 ; if 14, fails
     wreg rAUD1SWEEP,$11
     wreg rAUD1HIGH,$85  ; just before next reload, so freq is still $506
     call ShouldBeAlmostOff

     jp   TestsPassed

INCLUDE "shell_end.inc"
