; Verifies corruption for each timing

DEF TEST_NAME EQUS "7-timing_effect"
INCLUDE "oam_bug.inc"

Main:
	loop_n_times Test,116
	check_crc $7D792E7C
	jp   TestsPassed

Test:
	inc  a
	ld   b,a
	push bc
	call DisableLCD
	call FillOAM
	call CorruptOAM
	call DisableLCD
	call CpOAM
	pop  bc

	jr   z,.done
	call PrintB
	call PrintNewline
	call PrintOAM
	call PrintNewline

.done:
	ret

CorruptOAM:
	wreg rLCDC,LCDC_ON | LCDC_BG_ON
	ld   a,b
	call DelayA20Cycles
	delay 86

	ld   de,$FE00
	inc  de

	ret

INCLUDE "shell_end.inc"
