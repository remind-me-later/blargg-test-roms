; Things that don't cause corruption

DEF TEST_NAME EQUS "3-non_causes"
INCLUDE "oam_bug.inc"

Main:
	save_sp

	set_test 2, "When LCD is off"
	call DisableLCD
	call FillOAM
	ld bc, 2 * 70224/11 ; a couple of frames
	ld de, $FE00
.loop:
	inc de
	dec bc
	dec de
	ld a, b
	or c
	jr nz, .loop
	call End

	set_test 3, "LD DE,$FF00 : DEC DE"
	call Begin
	ld de, $FF00
	dec de
	call End

	set_test 4, "LD DE,$FDFF : INC DE"
	call Begin
	ld de, $FDFF
	inc de
	call End

	set_test 5, "LD DE,$7E00 : INC DE"
	call Begin
	ld de, $7E00
	inc de
	call End

	set_test 6, "LD DE,$FE00 : INC E"
	call Begin
	ld de, $FE00
	inc e
	call End

	set_test 7, "LD SP,$FDFE : POP BC"
	call Begin
	ld sp, $FDFE
	pop bc
	restore_sp
	call End

	set_test 8, "LD SP,$FE00 : LD HL,SP+1"
	call Begin
	ld sp, $FE00
	ld hl, sp+1
	restore_sp
	call End

	set_test 9, "LD HL,$FE00 : LD BC,$0001 : ADD HL,BC"
	call Begin
	ld hl, $FE00
	ld bc, $0001
	add hl, bc
	call End

	set_test 10, "LD SP,$FE00 : ADD SP,1"
	call Begin
	ld sp, $FE00
	add sp, 1
	restore_sp
	call End

	jp TestsPassed

Begin:
	call DisableLCD
	call FillOAM
	wreg rLCDC, LCDC_ON | LCDC_BG_ON
	delay 70224 - 6
	ret

End:
	call DisableLCD
	call CpOAM
	jp nz, TestFailed
	ret

INCLUDE "shell_end.inc"
