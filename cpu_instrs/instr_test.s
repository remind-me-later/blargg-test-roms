; Framework for CPU instruction tests

; Calls test_instr with each instruction copied
; to instr, with a JP instr_done after it.
; Verifies checksum after testing instruction and
; prints opcode if it's wrong.

INCLUDE "checksums.s"
INCLUDE "cpu_speed.s"
INCLUDE "apu.s"
INCLUDE "crc_fast.s"

; Where the instruction under test is copied, and a place for the registers
; it uses
PUSHS UNION "Instruction under test", WRAMX[$DEF8 - 4], BANK[1]
wRpTemp:        ds 4
wInstr:         ds 6    ; the instruction, then JP instr_done
POPS

PUSHS UNION "Test variables", WRAMX[wCrcTablesEnd], BANK[1]
wTemp:          ds 4
POPS

; Sets SP to word at addr
; Preserved: BC, DE
MACRO ldsp ; addr
     ld   a,[\1]
     ld   l,a
     ld   a,[(\1)+1]
     ld   h,a
     ld   sp,hl
ENDM

main:
     call cpu_fast
     call init_crc_fast
     call checksums_init
     set_test 0

     ld   hl,instrs
.next_instr:
     ; Copy instruction
     ld   a,[hli]
     ld   [wInstr],a
     ld   a,[hli]
     ld   [wInstr+1],a
     ld   a,[hli]
     ld   [wInstr+2],a
     push hl

     ; Put JP instr_done after it
     ld   a,$C3
     ld   [wInstr+3],a
     ld   a,LOW(instr_done)
     ld   [wInstr+4],a
     ld   a,HIGH(instr_done)
     ld   [wInstr+5],a

     call reset_crc
     call test_instr

     call checksums_compare
     jr   z,.passed

     set_test 1
     ld   a,[wInstr]
     call print_a
     cp   $CB
     jr   nz,.one_byte
     ld   a,[wInstr+1]
     call print_a
.one_byte:

.passed:
     ; Next instruction
     pop  hl
     ld   a,l
     cp   LOW(instrs_end)
     jr   nz,.next_instr
     ld   a,h
     cp   HIGH(instrs_end)
     jr   nz,.next_instr

     jp   tests_done


; Updates checksum with AF, BC, DE, and HL
checksum_af_bc_de_hl:
     push hl

     push af
     update_crc_fast_inline
     pop  hl
     ld   a,l
     update_crc_fast_inline

     ld   a,b
     update_crc_fast_inline
     ld   a,c
     update_crc_fast_inline

     ld   a,d
     update_crc_fast_inline
     ld   a,e
     update_crc_fast_inline

     pop  de
     ld   a,d
     update_crc_fast_inline
     ld   a,e
     update_crc_fast_inline
     ret
