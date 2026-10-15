; Tests DI, EI, and HALT (STOP proved untestable)

DEF TEST_NAME EQUS "02-interrupts"
INCLUDE "shell.inc"

Main:
	wreg rIE, $04

	set_test 2, "EI"
	ei
	ld bc, 0
	push bc
	pop bc
	inc b
	wreg rIF, $04
InterruptAddr:
	dec b
	jp nz, TestFailed
	ld hl, sp-2
	ld a, [hli]
	cp LOW(InterruptAddr)
	jp nz, TestFailed
	ld a, [hl]
	cp HIGH(InterruptAddr)
	jp nz, TestFailed
	lda rIF
	and $04
	jp nz, TestFailed

	set_test 3, "DI"
	di
	ld bc, 0
	push bc
	pop bc
	wreg rIF, $04
	ld hl, sp-2
	ld a, [hli]
	or [hl]
	jp nz, TestFailed
	lda rIF
	and $04
	jp z, TestFailed

	set_test 4, "Timer doesn't work"
	wreg rTAC, $05
	wreg rTIMA, 0
	wreg rIF, 0
	delay 500
	lda rIF
	delay 500
	and $04
	jp nz, TestFailed
	delay 500
	lda rIF
	and $04
	jp z, TestFailed
	pop af

	set_test 5, "HALT"
	wreg rTAC, $05
	wreg rTIMA, 0
	wreg rIF, 0
	halt ; timer interrupt will exit halt
	nop  ; avoids DMG bug
	lda rIF
	and $04
	jp z, TestFailed

	jp TestsPassed

; The multi-test ROM has this vector already, from test 07
IF !DEF(BUILD_MULTI)
PUSHS
SECTION "vector 1", ROM0[$50]
	inc a
	ret
POPS
ENDC

INCLUDE "shell_end.inc"
