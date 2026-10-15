; Verifies corruption at timing edges:
; * Beginning of first scanline, and 18 cycles later
; * Beginning of second scanline
; * End of last scanline

DEF TEST_NAME EQUS "5-timing_bug"
INCLUDE "oam_bug.inc"

Main:
	set_test 2, "Should corrupt at beginning of first scanline"
	call Begin
	call End

	set_test 3, "Should corrupt at +18 of first scanline"
	call Begin
	delay 18
	call End

	set_test 4, "Should corrupt at beginning of second scanline"
	call Begin
	delay 114
	call End

	set_test 5, "Should corrupt at +18 of last scanline"
	call Begin
	delay 114*143+18
	call End

	jp TestsPassed

Begin:
	call DisableLCD
	call FillOAM
	wreg rLCDC, LCDC_ON | LCDC_BG_ON
	delay 70224 - 15
	ret

End:
	ld de, $FE00
	inc de
	call DisableLCD
	call CpOAM
	jp z, TestFailed
	ret

INCLUDE "shell_end.inc"
