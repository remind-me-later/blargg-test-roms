; Tests most register instructions.
; Takes 15 seconds.

;DEF PRINT_CHECKSUMS EQU 1
DEF TEST_NAME EQUS "10-bit ops"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

Instrs:
	db $CB, $40, 0 ; BIT  0,B
	db $CB, $41, 0 ; BIT  0,C
	db $CB, $42, 0 ; BIT  0,D
	db $CB, $43, 0 ; BIT  0,E
	db $CB, $44, 0 ; BIT  0,H
	db $CB, $45, 0 ; BIT  0,L
	db $CB, $47, 0 ; BIT  0,A

	db $CB, $48, 0 ; BIT  1,B
	db $CB, $49, 0 ; BIT  1,C
	db $CB, $4A, 0 ; BIT  1,D
	db $CB, $4B, 0 ; BIT  1,E
	db $CB, $4C, 0 ; BIT  1,H
	db $CB, $4D, 0 ; BIT  1,L
	db $CB, $4F, 0 ; BIT  1,A

	db $CB, $50, 0 ; BIT  2,B
	db $CB, $51, 0 ; BIT  2,C
	db $CB, $52, 0 ; BIT  2,D
	db $CB, $53, 0 ; BIT  2,E
	db $CB, $54, 0 ; BIT  2,H
	db $CB, $55, 0 ; BIT  2,L
	db $CB, $57, 0 ; BIT  2,A

	db $CB, $58, 0 ; BIT  3,B
	db $CB, $59, 0 ; BIT  3,C
	db $CB, $5A, 0 ; BIT  3,D
	db $CB, $5B, 0 ; BIT  3,E
	db $CB, $5C, 0 ; BIT  3,H
	db $CB, $5D, 0 ; BIT  3,L
	db $CB, $5F, 0 ; BIT  3,A

	db $CB, $60, 0 ; BIT  4,B
	db $CB, $61, 0 ; BIT  4,C
	db $CB, $62, 0 ; BIT  4,D
	db $CB, $63, 0 ; BIT  4,E
	db $CB, $64, 0 ; BIT  4,H
	db $CB, $65, 0 ; BIT  4,L
	db $CB, $67, 0 ; BIT  4,A

	db $CB, $68, 0 ; BIT  5,B
	db $CB, $69, 0 ; BIT  5,C
	db $CB, $6A, 0 ; BIT  5,D
	db $CB, $6B, 0 ; BIT  5,E
	db $CB, $6C, 0 ; BIT  5,H
	db $CB, $6D, 0 ; BIT  5,L
	db $CB, $6F, 0 ; BIT  5,A

	db $CB, $70, 0 ; BIT  6,B
	db $CB, $71, 0 ; BIT  6,C
	db $CB, $72, 0 ; BIT  6,D
	db $CB, $73, 0 ; BIT  6,E
	db $CB, $74, 0 ; BIT  6,H
	db $CB, $75, 0 ; BIT  6,L
	db $CB, $77, 0 ; BIT  6,A

	db $CB, $78, 0 ; BIT  7,B
	db $CB, $79, 0 ; BIT  7,C
	db $CB, $7A, 0 ; BIT  7,D
	db $CB, $7B, 0 ; BIT  7,E
	db $CB, $7C, 0 ; BIT  7,H
	db $CB, $7D, 0 ; BIT  7,L
	db $CB, $7F, 0 ; BIT  7,A

	db $CB, $80, 0 ; RES  0,B
	db $CB, $81, 0 ; RES  0,C
	db $CB, $82, 0 ; RES  0,D
	db $CB, $83, 0 ; RES  0,E
	db $CB, $84, 0 ; RES  0,H
	db $CB, $85, 0 ; RES  0,L
	db $CB, $87, 0 ; RES  0,A

	db $CB, $88, 0 ; RES  1,B
	db $CB, $89, 0 ; RES  1,C
	db $CB, $8A, 0 ; RES  1,D
	db $CB, $8B, 0 ; RES  1,E
	db $CB, $8C, 0 ; RES  1,H
	db $CB, $8D, 0 ; RES  1,L
	db $CB, $8F, 0 ; RES  1,A

	db $CB, $90, 0 ; RES  2,B
	db $CB, $91, 0 ; RES  2,C
	db $CB, $92, 0 ; RES  2,D
	db $CB, $93, 0 ; RES  2,E
	db $CB, $94, 0 ; RES  2,H
	db $CB, $95, 0 ; RES  2,L
	db $CB, $97, 0 ; RES  2,A

	db $CB, $98, 0 ; RES  3,B
	db $CB, $99, 0 ; RES  3,C
	db $CB, $9A, 0 ; RES  3,D
	db $CB, $9B, 0 ; RES  3,E
	db $CB, $9C, 0 ; RES  3,H
	db $CB, $9D, 0 ; RES  3,L
	db $CB, $9F, 0 ; RES  3,A

	db $CB, $A0, 0 ; RES  4,B
	db $CB, $A1, 0 ; RES  4,C
	db $CB, $A2, 0 ; RES  4,D
	db $CB, $A3, 0 ; RES  4,E
	db $CB, $A4, 0 ; RES  4,H
	db $CB, $A5, 0 ; RES  4,L
	db $CB, $A7, 0 ; RES  4,A

	db $CB, $A8, 0 ; RES  5,B
	db $CB, $A9, 0 ; RES  5,C
	db $CB, $AA, 0 ; RES  5,D
	db $CB, $AB, 0 ; RES  5,E
	db $CB, $AC, 0 ; RES  5,H
	db $CB, $AD, 0 ; RES  5,L
	db $CB, $AF, 0 ; RES  5,A

	db $CB, $B0, 0 ; RES  6,B
	db $CB, $B1, 0 ; RES  6,C
	db $CB, $B2, 0 ; RES  6,D
	db $CB, $B3, 0 ; RES  6,E
	db $CB, $B4, 0 ; RES  6,H
	db $CB, $B5, 0 ; RES  6,L
	db $CB, $B7, 0 ; RES  6,A

	db $CB, $B8, 0 ; RES  7,B
	db $CB, $B9, 0 ; RES  7,C
	db $CB, $BA, 0 ; RES  7,D
	db $CB, $BB, 0 ; RES  7,E
	db $CB, $BC, 0 ; RES  7,H
	db $CB, $BD, 0 ; RES  7,L
	db $CB, $BF, 0 ; RES  7,A

	db $CB, $C0, 0 ; SET  0,B
	db $CB, $C1, 0 ; SET  0,C
	db $CB, $C2, 0 ; SET  0,D
	db $CB, $C3, 0 ; SET  0,E
	db $CB, $C4, 0 ; SET  0,H
	db $CB, $C5, 0 ; SET  0,L
	db $CB, $C7, 0 ; SET  0,A

	db $CB, $C8, 0 ; SET  1,B
	db $CB, $C9, 0 ; SET  1,C
	db $CB, $CA, 0 ; SET  1,D
	db $CB, $CB, 0 ; SET  1,E
	db $CB, $CC, 0 ; SET  1,H
	db $CB, $CD, 0 ; SET  1,L
	db $CB, $CF, 0 ; SET  1,A

	db $CB, $D0, 0 ; SET  2,B
	db $CB, $D1, 0 ; SET  2,C
	db $CB, $D2, 0 ; SET  2,D
	db $CB, $D3, 0 ; SET  2,E
	db $CB, $D4, 0 ; SET  2,H
	db $CB, $D5, 0 ; SET  2,L
	db $CB, $D7, 0 ; SET  2,A

	db $CB, $D8, 0 ; SET  3,B
	db $CB, $D9, 0 ; SET  3,C
	db $CB, $DA, 0 ; SET  3,D
	db $CB, $DB, 0 ; SET  3,E
	db $CB, $DC, 0 ; SET  3,H
	db $CB, $DD, 0 ; SET  3,L
	db $CB, $DF, 0 ; SET  3,A

	db $CB, $E0, 0 ; SET  4,B
	db $CB, $E1, 0 ; SET  4,C
	db $CB, $E2, 0 ; SET  4,D
	db $CB, $E3, 0 ; SET  4,E
	db $CB, $E4, 0 ; SET  4,H
	db $CB, $E5, 0 ; SET  4,L
	db $CB, $E7, 0 ; SET  4,A

	db $CB, $E8, 0 ; SET  5,B
	db $CB, $E9, 0 ; SET  5,C
	db $CB, $EA, 0 ; SET  5,D
	db $CB, $EB, 0 ; SET  5,E
	db $CB, $EC, 0 ; SET  5,H
	db $CB, $ED, 0 ; SET  5,L
	db $CB, $EF, 0 ; SET  5,A

	db $CB, $F0, 0 ; SET  6,B
	db $CB, $F1, 0 ; SET  6,C
	db $CB, $F2, 0 ; SET  6,D
	db $CB, $F3, 0 ; SET  6,E
	db $CB, $F4, 0 ; SET  6,H
	db $CB, $F5, 0 ; SET  6,L
	db $CB, $F7, 0 ; SET  6,A

	db $CB, $F8, 0 ; SET  7,B
	db $CB, $F9, 0 ; SET  7,C
	db $CB, $FA, 0 ; SET  7,D
	db $CB, $FB, 0 ; SET  7,E
	db $CB, $FC, 0 ; SET  7,H
	db $CB, $FD, 0 ; SET  7,L
	db $CB, $FF, 0 ; SET  7,A
InstrsEnd:

TestInstr:
	ld   c,$00
	call Test
	ld   c,$F0
	call Test
	ret

Test:
	; Go through each value for A
	ld   hl,Values
ALoop:
	ld   b,[hl]
	push hl

	; Go through each value for other registers
	ld   hl,Values
ValuesLoop:
	push bc
	push hl

	push bc

	; BC
	ld   a,[hli]
	ld   b,a
	ld   a,[hli]
	ld   c,a

	; HL
	ld   a,[hli]
	ld   d,a
	ld   a,[hli]
	ld   e,a
	push de

	; DE
	ld   a,[hli]
	ld   d,a
	ld   a,[hli]
	ld   e,a

	pop  hl
	pop  af

;    call PrintRegs
	jp   wInstr
InstrDone:

	; Checksum registers
	call ChecksumAFBCDEHL

	pop  hl
	pop  bc
	inc  hl
	ld   a,l
	cp   LOW(ValuesEnd)
	jr   nz,ValuesLoop

	pop  hl
	inc  hl
	ld   a,l
	cp   LOW(ValuesEnd)
	jr   nz,ALoop

	ret

Values:
	db $00, $01, $02, $04, $08, $10, $20, $40, $80, $FF
ValuesEnd:
	db $00, $01, $02, $04, $08, $10, $20, $40, $80, $FF

Checksums:
	db $46, $51, $4A, $16, $D4, $18, $B2, $4E, $ED, $B5, $15, $EA, $74, $66, $66, $3E
	db $C2, $F3, $7F, $6A, $63, $CA, $62, $21, $72, $1E, $E4, $83, $6A, $56, $41, $1D
	db $91, $90, $DB, $38, $54, $0A, $6C, $24, $02, $9E, $EA, $5B, $6D, $A7, $CB, $80
	db $B4, $0B, $F3, $0F, $40, $38, $75, $BB, $AF, $30, $2B, $E5, $BD, $97, $D0, $33
	db $83, $CB, $FD, $0A, $BB, $21, $93, $95, $28, $2F, $A2, $F6, $1B, $5F, $47, $E5
	db $A3, $2E, $39, $63, $6C, $E0, $02, $BB, $78, $F1, $BA, $CB, $2C, $9F, $49, $E0
	db $6C, $E0, $02, $BB, $04, $28, $A9, $FD, $5E, $D7, $2E, $93, $1B, $78, $08, $00
	db $83, $CB, $FD, $0A, $BB, $21, $93, $95, $69, $17, $20, $96, $C3, $B4, $B6, $51
	db $C1, $4E, $C3, $05, $72, $D0, $25, $98, $44, $F0, $99, $B7, $B4, $0B, $F3, $0F
	db $54, $0A, $6C, $24, $45, $10, $2B, $9D, $86, $3C, $DF, $27, $02, $9E, $EA, $5B
	db $B7, $B6, $4F, $60, $70, $E0, $E1, $AA, $C2, $F3, $7F, $6A, $63, $CA, $62, $21
	db $80, $76, $41, $65, $AA, $3B, $D4, $2C, $ED, $B5, $15, $EA, $74, $66, $66, $3E
	db $AD, $FF, $A0, $43, $7B, $4C, $06, $A4, $15, $32, $EE, $44, $43, $A6, $68, $3B
	db $6F, $5D, $BE, $D4, $DA, $75, $1B, $EF, $9B, $4D, $99, $8F, $49, $E8, $A9, $1D
	db $F5, $1B, $58, $3A, $92, $25, $2D, $51, $38, $5C, $62, $05, $DD, $A9, $63, $AD
	db $E3, $78, $2F, $37, $90, $15, $DB, $62, $58, $E2, $E8, $35, $BB, $C1, $5A, $EA
	db $06, $FE, $28, $AA, $4F, $5D, $64, $BF, $83, $CF, $7F, $B2, $F9, $A9, $90, $BF
	db $DD, $06, $B6, $64, $25, $8A, $E0, $24, $FA, $40, $95, $13, $91, $61, $93, $0D
	db $69, $A8, $0E, $0B, $AE, $FD, $DF, $1A, $D4, $98, $D8, $11, $61, $E9, $16, $66
	db $BD, $82, $1F, $2C, $E2, $74, $26, $77, $13, $E4, $6A, $25, $D7, $DE, $8A, $4F
	db $1F, $7B, $47, $BC, $DA, $DB, $31, $E7, $2B, $06, $2C, $39, $15, $FC, $1C, $0B
	db $1A, $3B, $A0, $0F, $55, $E5, $D8, $1C, $6D, $6C, $7F, $B8, $14, $AD, $9C, $AF
	db $92, $B6, $60, $40, $76, $E6, $6D, $2F, $9E, $CA, $45, $6D, $54, $97, $47, $35
	db $EE, $39, $50, $63, $47, $8C, $8A, $AB, $18, $F7, $6D, $10, $B7, $A6, $74, $0C
	db $11, $24, $9C, $F5, $64, $5D, $FB, $16, $65, $1C, $59, $C6, $B9, $E3, $30, $52
	db $1D, $E4, $B8, $9E, $A3, $2F, $7B, $6F, $03, $20, $24, $41, $4C, $F7, $22, $B8
	db $92, $A7, $75, $E3, $1D, $F2, $5E, $FD, $B7, $A4, $F3, $34, $BF, $F7, $37, $CA
	db $67, $22, $D4, $4D, $DE, $1A, $99, $58, $B2, $65, $91, $12, $F2, $8C, $65, $08
	db $69, $E2, $9B, $D3, $94, $8C, $71, $F1, $D8, $22, $29, $53, $E8, $6A, $D9, $55
	db $3E, $24, $42, $EF, $38, $12, $AC, $02, $35, $84, $7D, $2C, $C2, $34, $AC, $E2
	db $4B, $AA, $E0, $31, $8F, $A0, $F2, $13, $A8, $4F, $7B, $98, $02, $16, $3B, $D4
	db $8D, $09, $58, $A4, $FF, $46, $CA, $17, $08, $AA, $78, $02, $4A, $CF, $72, $E1
	db $A8, $55, $52, $89, $F8, $FD, $D6, $4E, $22, $E7, $8F, $C6, $80, $F1, $BB, $3C
	db $09, $1B, $4A, $4A, $06, $A1, $FD, $54, $E4, $BF, $D8, $27, $14, $23, $42, $90
	db $B3, $7B, $55, $14, $77, $22, $EE, $92, $E9, $37, $76, $8C, $7D, $CF, $B7, $C7
	db $D2, $90, $17, $48, $BB, $52, $BC, $19, $AA, $91, $9F, $DC, $0D, $AA, $C9, $24
	db $C8, $45, $DF, $AB, $B3, $83, $A8, $9E, $0F, $AA, $62, $2F, $C4, $C0, $28, $BA
	db $32, $56, $99, $69, $C9, $77, $4B, $62, $6B, $FF, $B6, $DD, $42, $46, $7A, $00
	db $DA, $E9, $67, $4D, $46, $9C, $B5, $92, $04, $B5, $F6, $03, $01, $3C, $A2, $47
	db $40, $15, $4A, $D6, $04, $39, $BC, $2F, $E9, $E1, $39, $59, $9B, $6A, $A4, $12
	db $97, $23, $99, $30, $9E, $A6, $70, $AD, $C7, $1B, $D6, $1F, $05, $15, $D2, $5B
	db $29, $0F, $5A, $CC, $0A, $99, $A2, $68, $5D, $58, $ED, $9C, $B9, $82, $CD, $74

INCLUDE "shell_end.inc"
