; Tests basic length counter operation

DEF TEST_NAME EQUS "02-len ctr"
INCLUDE "shell.inc"
INCLUDE "test_chan.s"

Main:
	test_all_chans
	jp   TestsPassed

Begin:
	call SyncAPU
	delay 2048     ; avoid extra clocking due to quirks
	wchn 4,$40     ; avoid extra clocking due to quirks
	wchn 1,-4      ; length = 4
	wchn 4,$C0     ; trigger, enabling channel
	ret

ShouldBeOn:
	lda  hChanMask
	ld   b,a
	lda  rAUDENA
	and  b
	jp   z,TestFailed
	ret

ShouldBeAlmostOff:
	call ShouldBeOn
	delay_apu 1
ShouldBeOff:
	lda  hChanMask
	ld   b,a
	lda  rAUDENA
	and  b
	jp   nz,TestFailed
	ret

TestChan:
	set_test 2,"Length becoming 0 should clear status"
	call Begin
	delay_apu 3
	call ShouldBeAlmostOff

	set_test 3,"Length can be reloaded at any time"
	call Begin
	wchn 1,-10     ; length = 10
	delay_apu 9
	call ShouldBeAlmostOff

	set_test 4,"Attempting to load length with 0 should load with maximum"
	call Begin
	wchn 1,0       ; length = maximum
	lda  hChanMaxlen
	dec  a
	call DelayAPUCycles
	call ShouldBeAlmostOff

	set_test 5,"Trigger shouldn't affect length"
	call Begin
	delay_apu 1
	wchn 4,$C0     ; length unaffected
	delay_apu 2
	call ShouldBeAlmostOff

	set_test 6,"Trigger should treat 0 length as maximum"
	call Begin
	delay_apu 4    ; clocks length to 0
	wchn 4,$C0     ; trigger converts 0 to maximum
	lda  hChanMaxlen
	dec  a
	call DelayAPUCycles
	call ShouldBeAlmostOff

	set_test 7,"Trigger with disabled length should convert ","0 length to maximum"
	call Begin
	delay_apu 4    ; clocks length to 0
	wchn 4,$00     ; disable length
	wchn 4,$80     ; trigger converts 0 to maximum
	wchn 4,$40     ; enable length
	lda  hChanMaxlen
	dec  a
	call DelayAPUCycles
	call ShouldBeAlmostOff

	set_test 8,"Disabling length shouldn't re-enable channel"
	call Begin
	delay_apu 4    ; clocks length to 0
	call ShouldBeOff
	wchn 4,0       ; disable length
	call ShouldBeOff

	set_test 9,"Disabling length should stop length clocking"
	call Begin
	wchn 4,0       ; disable length
	delay_apu 4    ; length isn't affected
	wchn 4,$40     ; enable length
	delay_apu 3    ; clocks length to 1
	call ShouldBeAlmostOff

	set_test 10,"Reloading shouldn't re-enable channel"
	call Begin
	delay_apu 4    ; clocks length to 0
	call ShouldBeOff
	wchn 1,-2      ; length = 2
	call ShouldBeOff

	set_test 11,"Disabled channel should still clock length"
	call Begin
	delay_apu 4    ; clocks length to 0, disabling channel
	wchn 1,-8      ; length = 8
	delay_apu 4    ; clocks length to 4
	wchn 4,$C0     ; trigger, enabling channel
	delay_apu 3    ; clocks length to 1
	call ShouldBeAlmostOff

	set_test 12,"Disabled channel should still convert 0 load to max length"
	call Begin
	delay_apu 4    ; clocks length to 0, disabling channel
	wchn 1,0       ; length = maximum
	delay_apu 32   ; clock length 32 times
	wchn 4,$C0
	lda  hChanMaxlen
	sub  33
	call DelayAPUCycles
	call ShouldBeAlmostOff

	set_test 13,"Disabling DAC should disable channel immediately"
	call Begin
	delay_apu 2    ; clocks length to 2
	call ShouldBeOn
	wchn 0,$00     ; if wave channel, this disables DAC
	wchn 2,$07     ; if square/noise channel, this disables DAC
	call ShouldBeOff

	set_test 14,"Disabled DAC should prevent enable at trigger"
	call Begin
	wchn 0,$00     ; if wave channel, this disables DAC
	wchn 2,$07     ; if square/noise channel, this disables DAC
	wchn 4,$80     ; triggers channel but doesn't enable it
	call ShouldBeOff

	set_test 15,"Enabling DAC shouldn't re-enable channel"
	wchn 0,$80     ; if wave channel, this enables DAC
	wchn 2,$10     ; if square/noise channel, this enables DAC
	call Begin
	delay_apu 2
	call ShouldBeOn
	wchn 0,$00     ; if wave channel, this disables DAC
	wchn 2,$00     ; if square/noise channel, this disables DAC
	call ShouldBeOff
	wchn 0,$80     ; if wave channel, this enables DAC
	wchn 2,$10     ; if square/noise channel, this enables DAC
	call ShouldBeOff

	set_test 16,"Volume reaching 0 shouldn't disable channel"
	wchn 2,$11     ; envelope that reaches zero in less than
				; 20 length clocks (if wave channel, this just sets
				; volume to 0)
	call Begin
	wchn 1,-20
	delay_apu 19
	call ShouldBeAlmostOff

	ret

INCLUDE "shell_end.inc"
