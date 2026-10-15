; After powering sound off then on, NR12 and NR14 are 0
; and NR44 is unchanged. While powered off, writes to
; NR41 are NOT ignored.

DEF TEST_NAME EQUS "11-regs after power"
INCLUDE "shell.inc"
INCLUDE "apu.s"

Main:
	call SyncAPU
	ld   a,$FF
	call FillAPURegs

	; Power down for a moment
	wreg rAUDENA,AUDENA_OFF
	wreg rAUD4LEN,-$12
	wreg rAUD1ENV,$F0
	delay_msec 100
	wreg rAUDENA,AUDENA_ON

	set_test 2,"Powering off should clear NR12"
	call SyncAPU
	wreg rAUD1HIGH,$80
	lda  rAUDENA
	and  $01
	jp   nz,TestFailed

	set_test 3,"Powering off should clear NR13"
	call SyncAPU
	wreg rAUD1SWEEP,$11
	wreg rAUD1ENV,$08
	wreg rAUD1HIGH,$80
	delay_apu 20
	lda  rAUDENA
	and  $01
	jp   z,TestFailed

	set_test 4,"Powering off shouldn't affect NR41"
	call SyncAPU
	delay_clocks 8192   ; avoids extra length clocking
	wreg rAUD4ENV,$08
	wreg rAUD4GO,$C0
	delay_apu $11
	lda  rAUDENA
	and  $08
	jp   z,TestFailed
	delay_apu 1
	lda  rAUDENA
	and  $08
	jp   nz,TestFailed

	jp   TestsPassed

INCLUDE "shell_end.inc"
