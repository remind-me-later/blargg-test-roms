; Demonstrates exact timing for first scanline

; With LCD off, turning it on synchronizes to beginning
; of first visible scanline

DEF TEST_NAME EQUS "4-scanline_timing"
INCLUDE "oam_bug.inc"

Main:
	set_test 2, "INC DE just before first corruption"
	call Begin
	ld de, $FE00
	ld a, $81
	ldh [rLCDC], a ; LCD on
	delay 70224-3
	inc de
	call ShouldNotCorrupt

	set_test 3, "INC DE at first corruption"
	call Begin
	ld de, $FE00
	ld a, $81
	ldh [rLCDC], a ; LCD on
	delay 70224-2
	inc de
	call ShouldCorrupt

	set_test 4, "INC DE at last corruption"
	call Begin
	ld de, $FE00
	ld a, $81
	ldh [rLCDC], a ; LCD on
	delay 70224-2+18
	inc de
	call ShouldCorrupt

	set_test 5, "INC DE just after last corruption"
	call Begin
	ld de, $FE00
	ld a, $81
	ldh [rLCDC], a ; LCD on
	delay 70224-2+19
	inc de
	call ShouldNotCorrupt

	jp TestsPassed

Begin:
	call DisableLCD
	call FillOAM
	ret

ShouldNotCorrupt:
	call DisableLCD
	call CpOAM
	jp nz, TestFailed
	ret

ShouldCorrupt:
	call DisableLCD
	call CpOAM
	jp z, TestFailed
	ret

INCLUDE "shell_end.inc"
