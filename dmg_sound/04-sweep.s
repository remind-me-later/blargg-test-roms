; Calc = calculation of new frequency and check for > $7FF
; Update = modification of frequency with new calculated value
DEF TEST_NAME EQUS "04-sweep"
INCLUDE "shell.inc"
INCLUDE "apu.s"

Begin:
	call SyncSweep
	wreg rAUD1HIGH, $40
	wreg rAUD1LEN, -$21
	wreg rAUD1ENV, $08
	ret

ShouldBeAlmostOff:
	lda rAUDENA
	and $01
	jp z, TestFailed
	delay_apu 1
ShouldBeOff:
	lda rAUDENA
	and $01
	jp nz, TestFailed
	ret

Main:
	set_test 2, "If shift>0, calculates on trigger"
	call Begin
	wreg rAUD1SWEEP, $01
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C7
	call ShouldBeOff
	call Begin
	wreg rAUD1SWEEP, $11
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C7
	call ShouldBeOff

	set_test 3, "If shift=0, doesn't calculate on trigger"
	call Begin
	wreg rAUD1SWEEP, $10
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C7
	delay_apu 1
	call ShouldBeAlmostOff

	set_test 4, "If period=0, doesn't calculate"
	call Begin
	wreg rAUD1SWEEP, $00
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C7
	delay_apu $20
	call ShouldBeAlmostOff

	set_test 5, "After updating frequency, calculates a second time"
	call Begin
	wreg rAUD1SWEEP, $11
	wreg rAUD1LOW, $00
	wreg rAUD1HIGH, $C5
	delay_apu 1
	call ShouldBeAlmostOff

	set_test 6, "If calculation>$7FF, disables channel"
	call Begin
	wreg rAUD1SWEEP, $02
	wreg rAUD1LOW, $67
	wreg rAUD1HIGH, $C6
	call ShouldBeOff

	set_test 7, "If calculation<=$7FF, doesn't disable channel"
	call Begin
	wreg rAUD1SWEEP, $01
	wreg rAUD1LOW, $55
	wreg rAUD1HIGH, $C5
	delay_apu $20
	call ShouldBeAlmostOff

	set_test 8, "If shift=0 and period>0, trigger enables"
	call Begin
	wreg rAUD1SWEEP, $10
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C3
	delay_apu 2
	wreg rAUD1SWEEP, $11
	delay_apu 1
	call ShouldBeAlmostOff

	set_test 9, "If shift>0 and period=0, trigger enables"
	call Begin
	wreg rAUD1SWEEP, $01
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C3
	delay_apu 15
	wreg rAUD1SWEEP, $11
	call ShouldBeAlmostOff

	set_test 10, "If shift=0 and period=0, trigger disables"
	call Begin
	wreg rAUD1SWEEP, $08
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C3
	wreg rAUD1SWEEP, $11
	delay_apu $20
	call ShouldBeAlmostOff

	set_test 11, "If shift=0, doesn't update"
	call Begin
	wreg rAUD1SWEEP, $10
	wreg rAUD1LOW, $FF
	wreg rAUD1HIGH, $C3
	delay_apu $20
	call ShouldBeAlmostOff

	set_test 12, "If period=0, doesn't update"
	call Begin
	wreg rAUD1SWEEP, $01
	wreg rAUD1LOW, $00
	wreg rAUD1HIGH, $C5
	delay_apu $20
	call ShouldBeAlmostOff

	jp TestsPassed

INCLUDE "shell_end.inc"
