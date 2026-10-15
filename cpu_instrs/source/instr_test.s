; Framework for CPU instruction tests

; Calls test_instr with each instruction copied
; to instr, with a JP instr_done after it.
; Verifies checksum after testing instruction and
; prints opcode if it's wrong.

INCLUDE "checksums.s"
INCLUDE "cpu_speed.s"
INCLUDE "apu.s"
INCLUDE "crc_fast.s"

DEF instr = $DEF8
DEF rp_temp = (instr-4)

DEF temp = bss

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
:    ; Copy instruction
     ld   a,[hli]
     ld   [instr],a
     ld   a,[hli]
     ld   [instr+1],a
     ld   a,[hli]
     ld   [instr+2],a
     push hl

     ; Put JP instr_done after it
     ld   a,$C3
     ld   [instr+3],a
     ld   a,LOW(instr_done)
     ld   [instr+4],a
     ld   a,HIGH(instr_done)
     ld   [instr+5],a

     call reset_crc
     call test_instr

     call checksums_compare
     jr   z,passed

     set_test 1
     ld   a,[instr]
     call print_a
     cp   $CB
     jr   nz,:+
     ld   a,[instr+1]
     call print_a
:

passed:
     ; Next instruction
     pop  hl
     ld   a,l
     cp   LOW(instrs_end)
     jr   nz,:--
     ld   a,h
     cp   HIGH(instrs_end)
     jr   nz,:--

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
