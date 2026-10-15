; Calc = calculation of new frequency and check for > $7FF
; Update = modification of frequency with new calculated value
DEF TEST_NAME EQUS "04-sweep"
INCLUDE "shell.inc"
INCLUDE "apu.s"

begin:
     call sync_sweep
     wreg rAUD1HIGH,$40
     wreg rAUD1LEN,-$21
     wreg rAUD1ENV,$08
     ret

should_be_almost_off:
     lda  rAUDENA
     and  $01
     jp   z,test_failed
     delay_apu 1
should_be_off:
     lda  rAUDENA
     and  $01
     jp   nz,test_failed
     ret

main:
     set_test 2,"If shift>0, calculates on trigger"
     call begin
     wreg rAUD1SWEEP,$01
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C7
     call should_be_off
     call begin
     wreg rAUD1SWEEP,$11
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C7
     call should_be_off

     set_test 3,"If shift=0, doesn't calculate on trigger"
     call begin
     wreg rAUD1SWEEP,$10
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C7
     delay_apu 1
     call should_be_almost_off

     set_test 4,"If period=0, doesn't calculate"
     call begin
     wreg rAUD1SWEEP,$00
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C7
     delay_apu $20
     call should_be_almost_off

     set_test 5,"After updating frequency, calculates a second time"
     call begin
     wreg rAUD1SWEEP,$11
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$C5
     delay_apu 1
     call should_be_almost_off

     set_test 6,"If calculation>$7FF, disables channel"
     call begin
     wreg rAUD1SWEEP,$02
     wreg rAUD1LOW,$67
     wreg rAUD1HIGH,$C6
     call should_be_off

     set_test 7,"If calculation<=$7FF, doesn't disable channel"
     call begin
     wreg rAUD1SWEEP,$01
     wreg rAUD1LOW,$55
     wreg rAUD1HIGH,$C5
     delay_apu $20
     call should_be_almost_off

     set_test 8,"If shift=0 and period>0, trigger enables"
     call begin
     wreg rAUD1SWEEP,$10
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C3
     delay_apu 2
     wreg rAUD1SWEEP,$11
     delay_apu 1
     call should_be_almost_off

     set_test 9,"If shift>0 and period=0, trigger enables"
     call begin
     wreg rAUD1SWEEP,$01
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C3
     delay_apu 15
     wreg rAUD1SWEEP,$11
     call should_be_almost_off

     set_test 10,"If shift=0 and period=0, trigger disables"
     call begin
     wreg rAUD1SWEEP,$08
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C3
     wreg rAUD1SWEEP,$11
     delay_apu $20
     call should_be_almost_off

     set_test 11,"If shift=0, doesn't update"
     call begin
     wreg rAUD1SWEEP,$10
     wreg rAUD1LOW,$FF
     wreg rAUD1HIGH,$C3
     delay_apu $20
     call should_be_almost_off

     set_test 12,"If period=0, doesn't update"
     call begin
     wreg rAUD1SWEEP,$01
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$C5
     delay_apu $20
     call should_be_almost_off

     jp   tests_passed

INCLUDE "shell_end.inc"
