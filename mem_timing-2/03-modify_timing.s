; Tests timing of accesses made by
; memory read-modify-write instructions

DEF TEST_NAME EQUS "03-modify_timing"
DEF ROM_NAME EQUS "03-MODIFY_TIMIN"
INCLUDE "shell.inc"
INCLUDE "tima_64.s"

Instructions:
	; last values are read/write times
	db $35, $00, $00, 2, 3 ; DEC  (HL)
	db $34, $00, $00, 2, 3 ; INC  (HL)
	db $CB, $06, $00, 3, 4 ; RLC  (HL)
	db $CB, $0E, $00, 3, 4 ; RRC  (HL)
	db $CB, $16, $00, 3, 4 ; RL   (HL)
	db $CB, $1E, $00, 3, 4 ; RR   (HL)
	db $CB, $26, $00, 3, 4 ; SLA  (HL)
	db $CB, $2E, $00, 3, 4 ; SRA  (HL)
	db $CB, $36, $00, 3, 4 ; SWAP (HL)
	db $CB, $3E, $00, 3, 4 ; SRL  (HL)
	db $CB, $86, $00, 3, 4 ; RES  0,(HL)
	db $CB, $8E, $00, 3, 4 ; RES  1,(HL)
	db $CB, $96, $00, 3, 4 ; RES  2,(HL)
	db $CB, $9E, $00, 3, 4 ; RES  3,(HL)
	db $CB, $A6, $00, 3, 4 ; RES  4,(HL)
	db $CB, $AE, $00, 3, 4 ; RES  5,(HL)
	db $CB, $B6, $00, 3, 4 ; RES  6,(HL)
	db $CB, $BE, $00, 3, 4 ; RES  7,(HL)
	db $CB, $C6, $00, 3, 4 ; SET  0,(HL)
	db $CB, $CE, $00, 3, 4 ; SET  1,(HL)
	db $CB, $D6, $00, 3, 4 ; SET  2,(HL)
	db $CB, $DE, $00, 3, 4 ; SET  3,(HL)
	db $CB, $E6, $00, 3, 4 ; SET  4,(HL)
	db $CB, $EE, $00, 3, 4 ; SET  5,(HL)
	db $CB, $F6, $00, 3, 4 ; SET  6,(HL)
	db $CB, $FE, $00, 3, 4 ; SET  7,(HL)
InstructionsEnd:

Main:
	call InitTIMA64
	set_test 0

	; Test instructions
	ld   hl,Instructions
.nextInstr:
	call .testInstr
	inc  hl
	ld   a,l
	cp   LOW(InstructionsEnd)
	jr   nz,.nextInstr

	jp   TestsDone

.testInstr:
	call .timeInstr
	ld   a,d
	cp   [hl]
	inc  hl
	jr   nz,.printFailed
	ld   a,e
	cp   [hl]
	ret  z
.printFailed:
	push hl
	ld   c,[hl]
	dec  hl
	ld   b,[hl]
	dec  hl
	dec  hl
	dec  hl
	ld   a,[hli]
	cp   $CB
	jr   nz,.opcode
	call PrintA
	ld   a,[hl]
.opcode:
	call PrintHex
	print_str ":"
	ld   a,d
	call PrintDec
	print_str "/"
	ld   a,e
	call PrintDec
	print_str "-"
	ld   a,b
	call PrintDec
	print_str "/"
	ld   a,c
	call PrintDec
	call PrintNewline
	pop  hl
	set_test 1
	ret

; Times instruction
; HL -> 3-byte instruction
; HL <- HL + 3
.timeInstr:
	; Copy instr
	ld   a,[hli]
	ld   [Instr+0],a
	ld   a,[hli]
	ld   [Instr+1],a
	ld   a,[hli]
	ld   [Instr+2],a
	push hl

	; Find result when access doesn't occur
	ld   b,0
	call .timeAccess

	; Find first access
	call .findNextAccess
	ld   d,b

	; Find second access
	call .findNextAccess
	ld   e,b

	pop  hl
	ret

; A -> current timer result
; B -> starting clock
; B <- clock next access occurs on
; A <- new timer result
.findNextAccess:
	ld   c,a
.again:
	call .timeAccess
	cp   c
	ret  nz
	inc  b
	ld   a,b
	cp   10
	jr   c,.again

	; Couldn't find time, so return 0/0
	ld   a,c
	ld   b,0
	ld   d,b
	ret

; Tests for access
; B -> which cycle to test
; A <- timer value after test
.timeAccess:
	call SyncTIMA64
	ld   hl,tima_64
	ld   [hl],$7F
	ld   a,17
	sub  b
	call DelayA20Cycles
	xor  a    ; clear flags
Instr:
	nop
	nop
	nop
	delay 32
	ld   a,[tima_64]
	ret

INCLUDE "shell_end.inc"
