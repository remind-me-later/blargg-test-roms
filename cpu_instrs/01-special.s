; Tests instructions that don't fit template

DEF TEST_NAME EQUS "01-special"
INCLUDE "shell.inc"

Main:
	set_test 2,"JR negative"
	ld   a,0
	jp   .jrNeg
	inc  a
.negTarget:
	inc  a
	inc  a
	cp   2
	jp   nz,TestFailed
	jp   .negDone
.jrNeg:
	jr   .negTarget
.negDone:

	set_test 3,"JR positive"
	ld   a,0
	jr   .posTarget
	inc  a
.posTarget:
	inc  a
	inc  a
	cp   2
	jp   nz,TestFailed


	set_test 4,"LD PC,HL"
	ld   hl,.hlTarget
	ld   a,0
	jp   hl
	inc  a
.hlTarget:
	inc  a
	inc  a
	cp   2
	jp   nz,TestFailed


	set_test 5,"POP AF"
	ld   bc,$1200
.popAF:
	push bc
	pop  af
	push af
	pop  de
	ld   a,c
	and  $F0
	cp   e
	jp   nz,TestFailed
	inc  b
	inc  c
	jr   nz,.popAF


	set_test 6,"DAA"
	; Test all combinations of A and flags (256*16 total)
	ld   de,0
.daa:
	push de
	pop  af
	daa

	push af
	call UpdateCRC
	pop  hl
	ld   a,l
	call UpdateCRC

	inc  d
	jr   nz,.daa

	ld   a,e
	add  $10
	ld   e,a
	jr   nz,.daa

	check_crc $6A9F8D8A

	jp   TestsPassed

INCLUDE "shell_end.inc"
