; Tests branch instructions

;DEF PRINT_CHECKSUMS EQU 1
DEF TEST_NAME EQUS "07-jr,jp,call,ret,rst"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

instrs:
     ;       JR cond,skip
     ;       INC A
     ; skip:
     db $18, $01, $3C ; JR   *+3
     db $20, $01, $3C ; JR   NZ,*+3
     db $28, $01, $3C ; JR   Z,*+3
     db $30, $01, $3C ; JR   NC,*+3
     db $38, $01, $3C ; JR   C,*+3

     db $C2, LOW(taken), HIGH(taken) ; JP   NZ,taken
     db $C3, LOW(taken), HIGH(taken) ; JP   taken
     db $CA, LOW(taken), HIGH(taken) ; JP   Z,taken
     db $D2, LOW(taken), HIGH(taken) ; JP   NC,taken
     db $DA, LOW(taken), HIGH(taken) ; JP   C,taken

     db $C4, LOW(taken), HIGH(taken) ; CALL NZ,taken
     db $CC, LOW(taken), HIGH(taken) ; CALL Z,taken
     db $CD, LOW(taken), HIGH(taken) ; CALL taken
     db $D4, LOW(taken), HIGH(taken) ; CALL NC,taken
     db $DC, LOW(taken), HIGH(taken) ; CALL C,taken

     ; RET cond
     ; INC A
     db $C0, $3C, 0 ; RET  NZ
     db $C8, $3C, 0 ; RET  Z
     db $C9, $3C, 0 ; RET
     db $D0, $3C, 0 ; RET  NC
     db $D8, $3C, 0 ; RET  C
     db $D9, $3C, 0 ; RETI

     ; RST
     ; can only easily test this one on devcart
     db $C7, 0, 0 ; RST $00
IF !DEF(BUILD_DEVCART)
     db $CF, 0, 0 ; RST $08
     db $D7, 0, 0 ; RST $10
     db $DF, 0, 0 ; RST $18
     db $E7, 0, 0 ; RST $20
     db $EF, 0, 0 ; RST $28
     db $F7, 0, 0 ; RST $30
     db $FF, 0, 0 ; RST $38
ENDC

instrs_end:

test_instr:
     wreg rIE,0 ; disable interrupts, since RETI does EI

     ; Go through all 16 combinations of flags
     ld   bc,$1200
.flags:
     ; Fill 4 bytes of new stack
     ld   a,$12
     ld   [$DF80-2],a
     ld   a,$34
     ld   [$DF80-3],a
     ld   a,$56
     ld   [$DF80-4],a
     ld   a,$78
     ld   [$DF80-5],a

     ; Set AF
     push bc
     pop  af

     ; Switch to new stack
     ld   [wTemp],sp
     ld   sp,$DF80

     ; Set return address
     ld   de,wInstr+3
     push de

     jp   wInstr
instr_done:
     inc  a
taken:
     di             ; RETI enables interrupts

     ; Save new SP and switch to yet another stack
     ld   [wTemp+2],sp
     ld   sp,$DF70

     ; Checksum A and SP
     call update_crc_fast
     ld   a,[wTemp+2]
     call update_crc_fast
     ld   a,[wTemp+3]
     call update_crc_fast

     ; Checksum 4 bytes of stack
     ld   a,[$DF80-2]
     call update_crc_fast
     ld   a,[$DF80-3]
     call update_crc_fast
     ld   a,[$DF80-4]
     call update_crc_fast
     ld   a,[$DF80-5]
     call update_crc_fast

     ldsp wTemp

     ld   a,c
     add  $10
     ld   c,a
     jr   nz,test_instr.flags

     ret

checksums:
     db $EC, $A4, $94, $79, $C4, $00, $96, $2C, $C4, $64, $90, $33, $77, $C7, $0A, $D4
     db $77, $A3, $0C, $CB, $79, $E7, $7E, $AE, $DA, $DC, $03, $F7, $4F, $9F, $E9, $20
     db $72, $12, $DA, $01, $44, $6A, $4D, $8F, $D1, $79, $30, $4C, $AA, $37, $F2, $6A
     db $97, $EA, $56, $5F, $32, $28, $C7, $D1, $49, $66, $05, $F7, $80, $0F, $BA, $8E
     db $41, $E2, $A4, $9A, $2D, $2D, $8C, $72, $A5, $13, $76, $A8, $64, $FE, $68, $BC
     db $2D, $2D, $8C, $72, $50, $96, $24, $27, $50, $96, $24, $27, $50, $96, $24, $27
     db $50, $96, $24, $27, $50, $96, $24, $27, $50, $96, $24, $27, $50, $96, $24, $27
     db $50, $96, $24, $27

INCLUDE "multi_custom.s"

INCLUDE "shell_end.inc"
