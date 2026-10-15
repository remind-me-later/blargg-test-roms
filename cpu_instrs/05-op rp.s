; Tests BC/DE/HL arithmetic

;DEF PRINT_CHECKSUMS EQU 1
DEF TEST_NAME EQUS "05-op rp"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

Instrs:
	db $0B, 0, 0 ; DEC  BC
	db $1B, 0, 0 ; DEC  DE
	db $2B, 0, 0 ; DEC  HL
	db $03, 0, 0 ; INC  BC
	db $13, 0, 0 ; INC  DE
	db $23, 0, 0 ; INC  HL
	db $09, 0, 0 ; ADD  HL,BC
	db $19, 0, 0 ; ADD  HL,DE
	db $29, 0, 0 ; ADD  HL,HL
InstrsEnd:

TestInstr:
	ld c, $00
	call Test
	ld c, $10
	call Test
	ld c, $E0
	call Test
	ld c, $F0
	call Test
	ret

Test:
	; Go through each value for HL
	ld hl, Values
HLLoop:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl

	; Go through each value for BC, DE, A
	ld hl, Values
ValuesLoop:
	push bc
	push de
	push hl

	push de
	push bc

	; BC
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl

	; DE
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl

	; HL, AF
	pop af
	ld a, [hl]
	pop hl

;    call PrintRegs
	jp wInstr
InstrDone:

	; Checksum registers
	call ChecksumAFBCDEHL

	pop hl
	pop de
	pop bc
	inc hl
	inc hl
	ld a, l
	cp LOW(ValuesEnd)
	jr nz, ValuesLoop

	pop hl
	ld a, l
	cp LOW(ValuesEnd)
	jr nz, HLLoop

	ret

Values:
	dw $0000, $0001, $000F, $0010, $001F, $007F, $0080, $00FF
	dw $0100, $0F00, $1F00, $1000, $7FFF, $8000, $FFFF
ValuesEnd:
	dw $0000, $0001, $000F, $0010, $001F, $007F, $0080, $00FF
	dw $0100, $0F00, $1F00, $1000, $7FFF, $8000, $FFFF

Checksums:
	db $C0, $A1, $36, $A3, $BE, $15, $B8, $2B, $9F, $93, $C6, $C2, $86, $C0, $07, $81, $0F, $75, $35, $38, $6B, $C7, $0A, $1B, $06, $68, $4B, $42, $64, $B4, $8C, $18, $FB, $6C, $31, $94

INCLUDE "shell_end.inc"
