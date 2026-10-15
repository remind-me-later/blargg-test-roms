; Tests most register instructions.
; Takes 10 seconds.

;DEF PRINT_CHECKSUMS EQU 1
DEF TEST_NAME EQUS "09-op r,r"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

Instrs:
     db $00, 0, 0 ; NOP
     db $2F, 0, 0 ; CPL
     db $37, 0, 0 ; SCF
     db $3F, 0, 0 ; CCF

     db $B0, 0, 0 ; OR   B
     db $B1, 0, 0 ; OR   C
     db $B2, 0, 0 ; OR   D
     db $B3, 0, 0 ; OR   E
     db $B4, 0, 0 ; OR   H
     db $B5, 0, 0 ; OR   L
     db $B7, 0, 0 ; OR   A

     db $B8, 0, 0 ; CP   B
     db $B9, 0, 0 ; CP   C
     db $BA, 0, 0 ; CP   D
     db $BB, 0, 0 ; CP   E
     db $BC, 0, 0 ; CP   H
     db $BD, 0, 0 ; CP   L
     db $BF, 0, 0 ; CP   A

     db $80, 0, 0 ; ADD  B
     db $81, 0, 0 ; ADD  C
     db $82, 0, 0 ; ADD  D
     db $83, 0, 0 ; ADD  E
     db $84, 0, 0 ; ADD  H
     db $85, 0, 0 ; ADD  L
     db $87, 0, 0 ; ADD  A

     db $88, 0, 0 ; ADC  B
     db $89, 0, 0 ; ADC  C
     db $8A, 0, 0 ; ADC  D
     db $8B, 0, 0 ; ADC  E
     db $8C, 0, 0 ; ADC  H
     db $8D, 0, 0 ; ADC  L
     db $8F, 0, 0 ; ADC  A

     db $90, 0, 0 ; SUB  B
     db $91, 0, 0 ; SUB  C
     db $92, 0, 0 ; SUB  D
     db $93, 0, 0 ; SUB  E
     db $94, 0, 0 ; SUB  H
     db $95, 0, 0 ; SUB  L
     db $97, 0, 0 ; SUB  A

     db $98, 0, 0 ; SBC  B
     db $99, 0, 0 ; SBC  C
     db $9A, 0, 0 ; SBC  D
     db $9B, 0, 0 ; SBC  E
     db $9C, 0, 0 ; SBC  H
     db $9D, 0, 0 ; SBC  L
     db $9F, 0, 0 ; SBC  A

     db $A0, 0, 0 ; AND  B
     db $A1, 0, 0 ; AND  C
     db $A2, 0, 0 ; AND  D
     db $A3, 0, 0 ; AND  E
     db $A4, 0, 0 ; AND  H
     db $A5, 0, 0 ; AND  L
     db $A7, 0, 0 ; AND  A

     db $A8, 0, 0 ; XOR  B
     db $A9, 0, 0 ; XOR  C
     db $AA, 0, 0 ; XOR  D
     db $AB, 0, 0 ; XOR  E
     db $AC, 0, 0 ; XOR  H
     db $AD, 0, 0 ; XOR  L
     db $AF, 0, 0 ; XOR  A

     db $05, 0, 0 ; DEC  B
     db $0D, 0, 0 ; DEC  C
     db $15, 0, 0 ; DEC  D
     db $1D, 0, 0 ; DEC  E
     db $25, 0, 0 ; DEC  H
     db $2D, 0, 0 ; DEC  L
     db $3D, 0, 0 ; DEC  A

     db $04, 0, 0 ; INC  B
     db $0C, 0, 0 ; INC  C
     db $14, 0, 0 ; INC  D
     db $1C, 0, 0 ; INC  E
     db $24, 0, 0 ; INC  H
     db $2C, 0, 0 ; INC  L
     db $3C, 0, 0 ; INC  A

     db $07, 0, 0 ; RLCA
     db $17, 0, 0 ; RLA
     db $0F, 0, 0 ; RRCA
     db $1F, 0, 0 ; RRA

     db $CB, $00, 0 ; RLC  B
     db $CB, $01, 0 ; RLC  C
     db $CB, $02, 0 ; RLC  D
     db $CB, $03, 0 ; RLC  E
     db $CB, $04, 0 ; RLC  H
     db $CB, $05, 0 ; RLC  L
     db $CB, $07, 0 ; RLC  A

     db $CB, $08, 0 ; RRC  B
     db $CB, $09, 0 ; RRC  C
     db $CB, $0A, 0 ; RRC  D
     db $CB, $0B, 0 ; RRC  E
     db $CB, $0C, 0 ; RRC  H
     db $CB, $0D, 0 ; RRC  L
     db $CB, $0F, 0 ; RRC  A

     db $CB, $10, 0 ; RL   B
     db $CB, $11, 0 ; RL   C
     db $CB, $12, 0 ; RL   D
     db $CB, $13, 0 ; RL   E
     db $CB, $14, 0 ; RL   H
     db $CB, $15, 0 ; RL   L
     db $CB, $17, 0 ; RL   A

     db $CB, $18, 0 ; RR   B
     db $CB, $19, 0 ; RR   C
     db $CB, $1A, 0 ; RR   D
     db $CB, $1B, 0 ; RR   E
     db $CB, $1C, 0 ; RR   H
     db $CB, $1D, 0 ; RR   L
     db $CB, $1F, 0 ; RR   A

     db $CB, $20, 0 ; SLA  B
     db $CB, $21, 0 ; SLA  C
     db $CB, $22, 0 ; SLA  D
     db $CB, $23, 0 ; SLA  E
     db $CB, $24, 0 ; SLA  H
     db $CB, $25, 0 ; SLA  L
     db $CB, $27, 0 ; SLA  A

     db $CB, $28, 0 ; SRA  B
     db $CB, $29, 0 ; SRA  C
     db $CB, $2A, 0 ; SRA  D
     db $CB, $2B, 0 ; SRA  E
     db $CB, $2C, 0 ; SRA  H
     db $CB, $2D, 0 ; SRA  L
     db $CB, $2F, 0 ; SRA  A

     db $CB, $30, 0 ; SWAP B
     db $CB, $31, 0 ; SWAP C
     db $CB, $32, 0 ; SWAP D
     db $CB, $33, 0 ; SWAP E
     db $CB, $34, 0 ; SWAP H
     db $CB, $35, 0 ; SWAP L
     db $CB, $37, 0 ; SWAP A

     db $CB, $38, 0 ; SRL  B
     db $CB, $39, 0 ; SRL  C
     db $CB, $3A, 0 ; SRL  D
     db $CB, $3B, 0 ; SRL  E
     db $CB, $3C, 0 ; SRL  H
     db $CB, $3D, 0 ; SRL  L
     db $CB, $3F, 0 ; SRL  A
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
     db $00, $01, $0F, $10, $1F, $7F, $80, $F0, $FF
ValuesEnd:
     db $00, $01, $0F, $10, $1F, $7F, $80, $F0, $FF

Checksums:
     db $7C, $55, $BD, $05, $BA, $C7, $AC, $D1, $74, $6D, $82, $4A, $0F, $06, $2A, $C5
     db $FA, $97, $9B, $9D, $C3, $32, $A0, $78, $00, $C1, $9F, $69, $C0, $D1, $C2, $A1
     db $55, $0D, $3F, $C8, $09, $7D, $97, $92, $CE, $66, $30, $56, $95, $F3, $01, $A1
     db $5B, $97, $54, $4C, $56, $FC, $A0, $89, $42, $F8, $7B, $2A, $E6, $7C, $03, $40
     db $45, $60, $C5, $A8, $B7, $BF, $B0, $EF, $A0, $7A, $1B, $4F, $FB, $22, $B4, $33
     db $06, $3D, $B5, $C7, $3C, $A4, $D5, $23, $C1, $BE, $75, $8B, $E0, $9B, $98, $BB
     db $0E, $75, $D9, $E6, $82, $A7, $E2, $66, $CD, $78, $4F, $E8, $8E, $D4, $2D, $3E
     db $88, $5C, $58, $C7, $F9, $20, $5F, $B9, $A8, $E4, $CA, $5E, $C8, $DB, $88, $94
     db $A3, $0D, $87, $60, $8B, $BA, $2B, $27, $41, $88, $83, $B1, $0A, $41, $9E, $D6
     db $98, $8D, $19, $B7, $13, $C6, $D5, $BF, $83, $CE, $74, $9F, $00, $34, $07, $5E
     db $F0, $E1, $1A, $68, $8F, $BA, $85, $A7, $A0, $46, $06, $A5, $75, $F9, $83, $48
     db $12, $EF, $1B, $03, $C8, $FB, $79, $EA, $9B, $00, $6C, $A9, $0D, $5E, $CB, $57
     db $41, $1B, $4B, $0C, $B2, $08, $D8, $E3, $43, $07, $E1, $93, $34, $73, $23, $C9
     db $18, $2F, $38, $F9, $D1, $3B, $AB, $5A, $BF, $C6, $F8, $03, $50, $0C, $A4, $32
     db $6B, $06, $7E, $FE, $ED, $8B, $D4, $15, $29, $46, $6D, $24, $6E, $5B, $15, $1A
     db $32, $AE, $87, $B0, $DC, $20, $AC, $4B, $2B, $63, $60, $C7, $C1, $92, $75, $AA
     db $6F, $CA, $17, $53, $5A, $C5, $78, $EA, $61, $01, $10, $83, $DD, $08, $D8, $78
     db $CA, $0B, $F5, $1F, $92, $55, $08, $01, $7F, $EA, $CD, $9B, $2A, $AA, $73, $17
     db $E0, $9F, $D0, $BA, $E7, $73, $72, $3D, $B7, $95, $2F, $3B, $A7, $78, $50, $36
     db $81, $04, $5B, $9E, $9A, $DE, $A4, $DD, $21, $B2, $9B, $36, $9F, $D7, $C8, $32
     db $48, $0E, $FC, $E5, $55, $C3, $53, $75, $A4, $ED, $A9, $E0, $9E, $78, $A7, $1D
     db $B8, $F4, $7C, $D6, $90, $2A, $03, $87, $81, $D8, $D5, $90, $63, $02, $C4, $52
     db $C2, $BE, $85, $B3, $32, $9A, $9E, $2D, $E3, $FB, $22, $47, $8E, $65, $08, $73
     db $72, $5A, $73, $95, $ED, $EC, $59, $9D, $C8, $67, $68, $F1, $4B, $ED, $41, $D5
     db $68, $39, $75, $F3, $FC, $09, $EF, $0D, $20, $2B, $43, $A3, $69, $AA, $89, $4F
     db $84, $87, $7B, $58, $42, $0A, $56, $EF, $1B, $0E, $19, $CA, $6F, $1B, $F9, $17
     db $EA, $B6, $4C, $B2, $1A, $C4, $C0, $B1, $E2, $B2, $45, $4E, $91, $0A, $8D, $AE
     db $17, $31, $55, $A3, $1B, $69, $72, $D8, $03, $E9, $55, $8D, $87, $27, $36, $63
     db $E6, $85, $12, $D1, $F2, $32, $97, $4D, $B5, $FA, $08, $A9, $97, $2A, $5A, $C2
     db $FD, $2D, $A4, $27, $57, $7C, $EC, $BD, $CC, $67, $19, $21, $46, $D4, $CD, $D6
     db $CB, $55, $D4, $E2, $9E, $F3, $32, $2E, $AA, $F8, $BB, $B3, $F6, $3A, $CC, $08
     db $64, $8B, $C2, $5F, $58, $66, $AF, $67, $B3, $44, $2C, $66, $72, $E7, $3B, $3F
     db $5B, $87, $0C, $17, $58, $E2, $B4, $A0, $70, $18, $81, $E6, $42, $56, $12, $CE
     db $BB, $13, $46, $3C, $BE, $5A, $FB, $53

INCLUDE "shell_end.inc"
