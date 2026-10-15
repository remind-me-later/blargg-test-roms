; Tests miscellaneous instructions

;DEF PRINT_CHECKSUMS EQU 1
DEF TEST_NAME EQUS "08-misc instrs"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

instrs:
     db $F0, $91, 0   ; LDH  A,($91)
     db $E0, $91, 0   ; LDH  ($91),A
     db $F2, $00, 0   ; LDH  A,(C)
     db $E2, $00, 0   ; LDH  (C),A
     db $FA, $91, $FF ; LD   A,($FF91)
     db $EA, $91, $FF ; LD   ($FF91),A
     db $08, $91, $FF ; LD   ($FF91),SP
     db $01, $23, $01 ; LD   BC,$0123
     db $11, $23, $01 ; LD   DE,$0123
     db $21, $23, $01 ; LD   HL,$0123
     db $31, $23, $01 ; LD   SP,$0123
     db $F5, 0, 0     ; PUSH AF
     db $C5, 0, 0     ; PUSH BC
     db $D5, 0, 0     ; PUSH DE
     db $E5, 0, 0     ; PUSH HL
     db $F1, 0, 0     ; POP  AF
     db $C1, 0, 0     ; POP  BC
     db $D1, 0, 0     ; POP  DE
     db $E1, 0, 0     ; POP  HL
instrs_end:

test_instr:
     ; C = flags register
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
     ; Fill RAM
     ld   a,$FE
     ld   [$FF90],a
     ld   a,$DC
     ld   [$FF91],a
     ld   a,$BA
     ld   [$FF92],a

     ; Fill stack
     ld   a,$13
     ld   [$DF80],a
     ld   a,$57
     ld   [$DF80-1],a
     ld   a,$9B
     ld   [$DF80-2],a
     ld   a,$DF
     ld   [$DF80-3],a

     ; Set registers
     ld   b,$12
     push bc
     ld   bc,$5691
     ld   de,$9ABC
     ld   hl,$DEF0
     pop  af

     ; Switch stack
     ld   [wTemp],sp
     ld   sp,$DF80-2

     jp   wInstr
instr_done:
     ; Save new SP and switch to another stack
     ld   [wTemp+2],sp
     ld   sp,$DF70

     call checksum_af_bc_de_hl

     ; Checksum SP
     ld   a,[wTemp+2]
     call update_crc_fast
     ld   a,[wTemp+3]
     call update_crc_fast

     ; Checksum RAM
     ld   a,[$FF90]
     call update_crc_fast
     ld   a,[$FF91]
     call update_crc_fast
     ld   a,[$FF92]
     call update_crc_fast

     ; Checksum stack
     ld   a,[$DF80]
     call update_crc_fast
     ld   a,[$DF80-1]
     call update_crc_fast
     ld   a,[$DF80-2]
     call update_crc_fast
     ld   a,[$DF80-3]
     call update_crc_fast

     ; Restore SP
     ldsp wTemp

     ret

checksums:
     db $4D, $FF, $15, $97, $6D, $A7, $35, $65, $4D, $FF, $15, $97, $6D, $A7, $35, $65, $4D, $FF, $15, $97, $6D, $A7, $35, $65, $AD, $FA, $5E, $41, $D0, $78, $79, $C1, $AF, $66, $99, $34, $0D, $E1, $97, $99, $6F, $D0, $6F, $5D, $C3, $1F, $A3, $8A, $C2, $F1, $9C, $F3, $C1, $C3, $DC, $78, $C0, $2D, $E3, $01, $8F, $C4, $0F, $44, $95, $22, $6A, $39, $61, $C5, $AB, $55, $FB, $DF, $2C, $52,

INCLUDE "shell_end.inc"
