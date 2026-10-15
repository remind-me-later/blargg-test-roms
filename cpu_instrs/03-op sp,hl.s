; Tests SP/HL instructions

;DEF PRINT_CHECKSUMS EQU 1
DEF TEST_NAME EQUS "03-op sp,hl"
INCLUDE "shell.inc"
INCLUDE "instr_test.s"

Instrs:
     db $33, 0, 0     ; INC  SP
     db $3B, 0, 0     ; DEC  SP
     db $39, 0, 0     ; ADD  HL,SP
     db $F9, 0, 0     ; LD   SP,HL
     db $E8, $01, 0   ; ADD  SP,1
     db $E8, $FF, 0   ; ADD  SP,-1
     db $F8, $01, 0   ; LD   HL,SP+1
     db $F8, $FF, 0   ; LD   HL,SP-1
InstrsEnd:

TestInstr:
     ; C = flags register
     ld   c,$00
     call Test
     ld   c,$F0
     call Test
     ret

Test:
     ; Go through each value for HL
     ld   hl,Values
HLLoop:
     ld   e,[hl]
     inc  hl
     ld   d,[hl]
     inc  hl
     push hl

     ; Go through each value for SP
     ld   hl,Values
ValuesLoop:
     push bc
     push de
     push hl

     push bc
     pop  af

     ; Switch stack
     ld   [wTemp],sp
     ld   a,[hli]
     ld   h,[hl]
     ld   l,a
;    call PrintRegs
     ld   sp,hl

     ; Set registers
     ld   h,d
     ld   l,e
     ld   a,$12
     ld   bc,$5691
     ld   de,$9ABC

     jp   wInstr
InstrDone:
     ; Save new SP and switch to yet another stack
     ld   [wTemp+2],sp
     ld   sp,$DF70

     call ChecksumAFBCDEHL

     ; Checksum SP
     ld   a,[wTemp+2]
     call UpdateCRCFast
     ld   a,[wTemp+3]
     call UpdateCRCFast

     ldsp wTemp

     pop  hl
     pop  de
     pop  bc
     inc  hl
     inc  hl
     ld   a,l
     cp   LOW(ValuesEnd)
     jr   nz,ValuesLoop

     pop  hl
     ld   a,l
     cp   LOW(ValuesEnd)
     jr   nz,HLLoop

     ret

Values:
     dw $0000, $0001, $000F, $0010, $001F, $007F, $0080, $00FF
     dw $0100, $0F00, $1F00, $1000, $7FFF, $8000, $FFFF
ValuesEnd:
     dw $0000, $0001, $000F, $0010, $001F, $007F, $0080, $00FF
     dw $0100, $0F00, $1F00, $1000, $7FFF, $8000, $FFFF

Checksums:
     db $BC, $F4, $CD, $8C, $C7, $5E, $89, $E5, $36, $65, $21, $55, $D6, $6A, $2A, $FF
     db $EB, $34, $37, $B9, $08, $5F, $22, $13, $B6, $2A, $37, $C3, $72, $43, $5C, $4D

INCLUDE "shell_end.inc"
