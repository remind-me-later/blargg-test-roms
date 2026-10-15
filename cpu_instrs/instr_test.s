; Framework for CPU instruction tests

; Calls TestInstr with each instruction copied
; to wInstr, with a JP InstrDone after it.
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
wInstr:         ds 6    ; the instruction, then JP InstrDone
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

Main:
	call CPUFast
	call InitCRCFast
	call ChecksumsInit
	set_test 0

	ld   hl,Instrs
.nextInstr:
	; Copy instruction
	ld   a,[hli]
	ld   [wInstr],a
	ld   a,[hli]
	ld   [wInstr+1],a
	ld   a,[hli]
	ld   [wInstr+2],a
	push hl

	; Put JP InstrDone after it
	ld   a,$C3
	ld   [wInstr+3],a
	ld   a,LOW(InstrDone)
	ld   [wInstr+4],a
	ld   a,HIGH(InstrDone)
	ld   [wInstr+5],a

	call ResetCRC
	call TestInstr

	call ChecksumsCompare
	jr   z,.passed

	set_test 1
	ld   a,[wInstr]
	call PrintA
	cp   $CB
	jr   nz,.oneByte
	ld   a,[wInstr+1]
	call PrintA
.oneByte:

.passed:
	; Next instruction
	pop  hl
	ld   a,l
	cp   LOW(InstrsEnd)
	jr   nz,.nextInstr
	ld   a,h
	cp   HIGH(InstrsEnd)
	jr   nz,.nextInstr

	jp   TestsDone


; Updates checksum with AF, BC, DE, and HL
ChecksumAFBCDEHL:
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
