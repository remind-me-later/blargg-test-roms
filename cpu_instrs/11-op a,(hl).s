; Tests (HL/BC/DE) instructions.
; Takes 20 seconds.

;DEF PRINT_CHECKSUMS EQU 1
DEF TEST_NAME EQUS "11-op a,(hl)"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

Instrs:
	db $0A, 0, 0     ; LD   A,(BC)
	db $1A, 0, 0     ; LD   A,(DE)
	db $02, 0, 0     ; LD   (BC),A
	db $12, 0, 0     ; LD   (DE),A
	db $2A, 0, 0     ; LD   A,(HL+)
	db $3A, 0, 0     ; LD   A,(HL-)
	db $22, 0, 0     ; LD   (HL+),A
	db $32, 0, 0     ; LD   (HL-),A
	db $B6, 0, 0     ; OR   (HL)
	db $BE, 0, 0     ; CP   (HL)
	db $86, 0, 0     ; ADD  (HL)
	db $8E, 0, 0     ; ADC  (HL)
	db $96, 0, 0     ; SUB  (HL)
	db $9E, 0, 0     ; SBC  (HL)
	db $A6, 0, 0     ; AND  (HL)
	db $AE, 0, 0     ; XOR  (HL)
	db $35, 0, 0     ; DEC  (HL)
	db $34, 0, 0     ; INC  (HL)
	db $CB, $06, 0   ; RLC  (HL)
	db $CB, $0E, 0   ; RRC  (HL)
	db $CB, $16, 0   ; RL   (HL)
	db $CB, $1E, 0   ; RR   (HL)
	db $CB, $26, 0   ; SLA  (HL)
	db $CB, $2E, 0   ; SRA  (HL)
	db $CB, $36, 0   ; SWAP (HL)
	db $CB, $3E, 0   ; SRL  (HL)
	db $CB, $46, 0   ; BIT  0,(HL)
	db $CB, $4E, 0   ; BIT  1,(HL)
	db $CB, $56, 0   ; BIT  2,(HL)
	db $CB, $5E, 0   ; BIT  3,(HL)
	db $CB, $66, 0   ; BIT  4,(HL)
	db $CB, $6E, 0   ; BIT  5,(HL)
	db $CB, $76, 0   ; BIT  6,(HL)
	db $CB, $7E, 0   ; BIT  7,(HL)
	db $CB, $86, 0   ; RES  0,(HL)
	db $CB, $8E, 0   ; RES  1,(HL)
	db $CB, $96, 0   ; RES  2,(HL)
	db $CB, $9E, 0   ; RES  3,(HL)
	db $CB, $A6, 0   ; RES  4,(HL)
	db $CB, $AE, 0   ; RES  5,(HL)
	db $CB, $B6, 0   ; RES  6,(HL)
	db $CB, $BE, 0   ; RES  7,(HL)
	db $CB, $C6, 0   ; SET  0,(HL)
	db $CB, $CE, 0   ; SET  1,(HL)
	db $CB, $D6, 0   ; SET  2,(HL)
	db $CB, $DE, 0   ; SET  3,(HL)
	db $CB, $E6, 0   ; SET  4,(HL)
	db $CB, $EE, 0   ; SET  5,(HL)
	db $CB, $F6, 0   ; SET  6,(HL)
	db $CB, $FE, 0   ; SET  7,(HL)
	db $27, 0, 0     ; DAA
InstrsEnd:

TestInstr:
	ld   c,$00
	call Test
	ld   c,$10
	call Test
	ld   c,$E0
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

	; Go through each value for (HL)
	ld   hl,Values
ValuesLoop:
	push bc
	push hl

	push bc

	; BC
	ld   a,[hli]
	ld   bc,wRpTemp
	ld   [wRpTemp],a

	; DE
	ld   a,[hli]
	ld   de,wRpTemp+1
	ld   [wRpTemp+1],a

	; HL
	ld   a,[hl]
	ld   hl,wRpTemp+2
	ld   [wRpTemp+2],a

	; AF
	pop  af

;    call PrintRegs
	jp   wInstr
InstrDone:

	; Checksum AF, HL, and (HL)
	push hl
	push af
	call UpdateCRCFast
	pop  hl
	ld   a,l
	call UpdateCRCFast
	pop  bc
	ld   a,b
	call UpdateCRCFast
	ld   a,c
	call UpdateCRCFast
	ld   a,[wRpTemp]
	call UpdateCRCFast
	ld   a,[wRpTemp+1]
	call UpdateCRCFast
	ld   a,[wRpTemp+2]
	call UpdateCRCFast

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
	db $00, $01, $0F, $10, $1F, $7F, $80, $F0, $FF, $02, $04, $08, $20, $40
ValuesEnd:
	db $00, $01, $0F, $10, $1F, $7F, $80, $F0, $FF, $02, $04, $08, $20, $40

Checksums:
	db $E0, $E5, $09, $A7, $FB, $28, $0D, $AE, $AC, $BB, $91, $D8, $B3, $E2, $AF, $C4
	db $3D, $B5, $02, $07, $4F, $6E, $5B, $7E, $AE, $02, $E7, $14, $DC, $D9, $BE, $6D
	db $F1, $48, $A9, $42, $67, $08, $FE, $57, $06, $6A, $A9, $B1, $FD, $A5, $84, $F0
	db $82, $FC, $24, $A9, $A8, $1D, $BB, $E2, $F8, $23, $8C, $DE, $0E, $1D, $64, $D1
	db $05, $E0, $24, $41, $53, $75, $47, $55, $F4, $D9, $10, $6A, $38, $16, $28, $D8
	db $D1, $28, $A3, $E0, $A2, $05, $B8, $FE, $B0, $F4, $F5, $8F, $4B, $39, $03, $B0
	db $8A, $07, $BA, $90, $25, $99, $A7, $78, $E6, $9A, $D1, $49, $C9, $B2, $A3, $E5
	db $36, $34, $CB, $5A, $97, $42, $71, $09, $39, $87, $25, $EC, $54, $EE, $C5, $B3
	db $FC, $B5, $6F, $BD, $0B, $D8, $46, $6F, $6A, $27, $81, $9F, $F8, $38, $E2, $71
	db $55, $19, $21, $83, $4B, $85, $9F, $4B, $A1, $78, $14, $60, $58, $08, $D9, $57
	db $11, $8C, $83, $9A, $9F, $01, $D1, $90, $E8, $82, $0B, $5A, $BD, $75, $86, $21
	db $DF, $83, $E9, $23, $1E, $B6, $7F, $D1, $4A, $18, $A5, $8E, $CF, $CF, $CA, $51
	db $3F, $03, $A4, $96, $C3, $1F, $9E, $88, $0C, $DF, $1F, $B1

INCLUDE "shell_end.inc"
