; Verifies corruption pattern for each instruction

DEF TEST_NAME EQUS "8-instr_effect"
INCLUDE "oam_bug.inc"

Main:
	save_sp

	set_test 2,"INC/DEC rp pattern is wrong"
	call Begin
	ld   de,$FE00
	inc  de
	call End

	ld   de,$FE00
	dec  de
	call End
	check_crc $EF0C266A

	set_test 3,"POP rp pattern is wrong"
	call Begin
	ld   sp,$FEF0
	pop  bc
	restore_sp
	call End
	check_crc $8C62EE7D

	set_test 4,"PUSH rp pattern is wrong"
	call Begin
	ld   sp,$FEF0
	push bc
	restore_sp
	call End
	check_crc $B3693CEE

	set_test 5,"LD A,(HL+/-) pattern is wrong"
	call Begin
	ld   hl,$FEF0
	ld   a,[hli]
	call End

	ld   hl,$FEF0
	ld   a,[hld]
	call End
	check_crc $06BE41A4

	jp   TestsPassed

Begin:
	call DisableLCD
	call FillOAM
	wreg rLCDC,LCDC_ON | LCDC_BG_ON
	delay 70224 - 4
	ret

End:
	call DisableLCD
	call CpOAM
	jr   z,.unchanged
	call PrintOAM
	call PrintNewline
.unchanged:
	call Begin
	ret

INCLUDE "shell_end.inc"
