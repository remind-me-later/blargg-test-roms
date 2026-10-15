; Tests LD r,r ($40-$7F)

;DEF PRINT_CHECKSUMS = 1
DEF TEST_NAME EQUS "06-ld r,r"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

instrs:
     db $40, 0, 0 ; LD   B,B
     db $41, 0, 0 ; LD   B,C
     db $42, 0, 0 ; LD   B,D
     db $43, 0, 0 ; LD   B,E
     db $44, 0, 0 ; LD   B,H
     db $45, 0, 0 ; LD   B,L
     db $46, 0, 0 ; LD   B,(HL)
     db $47, 0, 0 ; LD   B,A

     db $48, 0, 0 ; LD   C,B
     db $49, 0, 0 ; LD   C,C
     db $4A, 0, 0 ; LD   C,D
     db $4B, 0, 0 ; LD   C,E
     db $4C, 0, 0 ; LD   C,H
     db $4D, 0, 0 ; LD   C,L
     db $4E, 0, 0 ; LD   C,(HL)
     db $4F, 0, 0 ; LD   C,A

     db $50, 0, 0 ; LD   D,B
     db $51, 0, 0 ; LD   D,C
     db $52, 0, 0 ; LD   D,D
     db $53, 0, 0 ; LD   D,E
     db $54, 0, 0 ; LD   D,H
     db $55, 0, 0 ; LD   D,L
     db $56, 0, 0 ; LD   D,(HL)
     db $57, 0, 0 ; LD   D,A

     db $58, 0, 0 ; LD   E,B
     db $59, 0, 0 ; LD   E,C
     db $5A, 0, 0 ; LD   E,D
     db $5B, 0, 0 ; LD   E,E
     db $5C, 0, 0 ; LD   E,H
     db $5D, 0, 0 ; LD   E,L
     db $5E, 0, 0 ; LD   E,(HL)
     db $5F, 0, 0 ; LD   E,A

     db $60, 0, 0 ; LD   H,B
     db $61, 0, 0 ; LD   H,C
     db $62, 0, 0 ; LD   H,D
     db $63, 0, 0 ; LD   H,E
     db $64, 0, 0 ; LD   H,H
     db $65, 0, 0 ; LD   H,L
     db $66, 0, 0 ; LD   H,(HL)
     db $67, 0, 0 ; LD   H,A

     db $68, 0, 0 ; LD   L,B
     db $69, 0, 0 ; LD   L,C
     db $6A, 0, 0 ; LD   L,D
     db $6B, 0, 0 ; LD   L,E
     db $6C, 0, 0 ; LD   L,H
     db $6D, 0, 0 ; LD   L,L
     db $6E, 0, 0 ; LD   L,(HL)
     db $6F, 0, 0 ; LD   L,A

     db $70, 0, 0 ; LD   (HL),B
     db $71, 0, 0 ; LD   (HL),C
     db $72, 0, 0 ; LD   (HL),D
     db $73, 0, 0 ; LD   (HL),E
     db $74, 0, 0 ; LD   (HL),H
     db $75, 0, 0 ; LD   (HL),L
     db $77, 0, 0 ; LD   (HL),A

     db $78, 0, 0 ; LD   A,B
     db $79, 0, 0 ; LD   A,C
     db $7A, 0, 0 ; LD   A,D
     db $7B, 0, 0 ; LD   A,E
     db $7C, 0, 0 ; LD   A,H
     db $7D, 0, 0 ; LD   A,L
     db $7E, 0, 0 ; LD   A,(HL)
     db $7F, 0, 0 ; LD   A,A
instrs_end:

test_instr:
     ld   c,$00
     call test
     ld   c,$10
     call test
     ld   c,$E0
     call test
     ld   c,$F0
     call test
     ret

test:
     ; Put different value in each register and (hl_temp)
     ld   b,$BC
     push bc
     ld   a,$DE
     ld   [rp_temp],a
     ld   a,$12
     ld   bc,$3456
     ld   de,$789A
     ld   hl,rp_temp ; (HL) points to RAM
     pop  af

;    call print_regs
     jp   instr
instr_done:

     ; Checksum registers and (HL)
     call checksum_af_bc_de_hl
     ld   a,[rp_temp]
     call update_crc_fast

     ret

checksums:
     db $40, $3A, $AF, $06, $B6, $CB, $B2, $AB, $6F, $EF, $71, $9B, $75, $E3, $6C, $B9, $34, $FB, $26, $B7, $5A, $B9, $2F, $CE, $34, $FB, $26, $B7, $C2, $0A, $3B, $1A, $2A, $8A, $D6, $7C, $40, $3A, $AF, $06, $AF, $0A, $74, $70, $19, $A9, $6E, $6F, $11, $DA, $FE, $FE, $18, $10, $04, $2B, $11, $DA, $FE, $FE, $7B, $6A, $87, $84, $8B, $87, $34, $12, $00, $45, $DE, $01, $40, $3A, $AF, $06, $93, $E2, $8F, $C6, $DD, $7D, $90, $32, $FF, $90, $1B, $A8, $DD, $7D, $90, $32, $56, $BF, $7A, $21, $23, $C0, $FA, $06, $3B, $1D, $A0, $80, $3F, $44, $1B, $9C, $40, $3A, $AF, $06, $56, $25, $85, $CD, $D7, $B1, $DB, $F9, $56, $25, $85, $CD, $4E, $F8, $DF, $4B, $F0, $C3, $F9, $18, $20, $0F, $F6, $91, $71, $69, $CE, $46, $F0, $A0, $03, $4D, $40, $3A, $AF, $06, $29, $47, $E2, $36, $40, $3A, $AF, $06, $90, $F6, $A0, $8F, $3D, $62, $26, $A9, $A4, $52, $C1, $75, $45, $ED, $75, $40, $8A, $4D, $63, $56, $AF, $BA, $2D, $FE, $40, $3A, $AF, $06, $AF, $BA, $2D, $FE, $36, $8A, $CA, $22, $34, $8D, $C2, $65, $1A, $DB, $FF, $54, $32, $C0, $E8, $55, $ED, $4A, $87, $2F, $40, $3A, $AF, $06, $9D, $BC, $81, $E6, $6E, $6C, $92, $37, $B1, $EC, $C3, $29, $1D, $C5, $9F, $A1, $59, $6F, $66, $CD, $B4, $FB, $FD, $74, $EC, $13, $F3, $8E, $70, $0C, $5F, $ED, $EC, $13, $F3, $8E, $40, $3A, $AF, $06,

INCLUDE "shell_end.inc"
