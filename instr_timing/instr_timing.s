; Tests number of cycles taken by instructions
; except STOP, HALT, and illegals.

DEF TEST_NAME EQUS "instr_timing"
DEF ROM_NAME EQUS "INSTR_TIMING"
; The tables have to follow the shell code, in the block of the program
DEF KEEP_PROGRAM_OPEN EQU 1
INCLUDE "shell.inc"
INCLUDE "timer.s"

PUSHS UNION "Test variables", WRAMX[wShellVariablesEnd], BANK[1]
wSavedSp:       dw
wInstr:         ds 6    ; 3-byte instr + JP InstrEnd
wInstrAddr:     ds 3    ; JP InstrEnd
POPS

Main:
	call InitTimer
	call TestTimer
	set_test 0
	call TestMainOps
	call TestCBOps
	jp   TestsDone


; Ensures timer works
TestTimer:
	call StartTimer
	call StopTimer
	or   a
	ret  z
	set_test 2,"Timer doesn't  work properly"
	jp   TestFailed


; Tests main opcodes
TestMainOps:
	ld   l,0
.nextOp:
	ld   h,HIGH(OpTimes)
	ld   a,[hl]
	cp   0
	call nz,.testOp
	inc  l
	jr   nz,.nextOp
	ret

.testOp:
	; Can't test the 8 RST instructions on devcart
	ld   a,l
	cpl
	and  $C7
	jr   nz,.test
	ld   a,[wGbId]
	and  GB_ID_DEVCART
	ret  nz
.test:
	; Test with flags set so that branches are
	; not taken
	ld   a,l  ; e = (l & 0x08 ? 0 : 0xFF)
	and  $08
	add  $F8
	ld   e,a
	call .copyAndExec
	ld   d,0
	cp   [hl]
	jr   z,.ok
	ld   d,a
	call PrintFailedOpcode
.ok:

	; Time with branches not taken
	ld   a,e
	cpl
	ld   e,a
	call .copyAndExec
	ld   h,HIGH(OpTimesTaken)
	cp   [hl]
	ret  z

	; If opcode already failed and timed the
	; same again, avoid re-reporting.
	cp   d
	ret  z

	call PrintFailedOpcode
	ret

.copyAndExec:
	push de
	push hl

	ld   h,HIGH(OpLens)
	ld   c,[hl]
	ld   a,l
	ld   hl,wInstr
	ld   [hli],a
	dec  c
	jr   z,.oneByte
	ld   a,0
	dec  c
	jr   z,.twoBytes
	ld   a,LOW(wInstrAddr)
	ld   [hli],a
	ld   a,HIGH(wInstrAddr)
.twoBytes:
	ld   [hli],a
.oneByte:
	ld   a,e
	call TimeInstruction

	pop  hl
	pop  de
	ret


; Tests CB opcodes
TestCBOps:
	ld   hl,CBOpTimes
.nextOp:
	ld   a,[hl]
	cp   0
	call nz,.testOpCB
	inc  l
	jr   nz,.nextOp
	ret

.testOpCB:
	; Test with flags clear
	ld   e,$00
	call .copyAndExecCB
	cp   [hl]
	jr   nz,.failed

	; Test with flags set
	ld   e,$FF
	call .copyAndExecCB
	cp   [hl]
	jr   nz,.failed

	ret
.failed:
	print_str "CB "
	call PrintFailedOpcode
	ret

.copyAndExecCB:
	push hl

	; Copy instr to exec space
	ld   a,l
	ld   hl,wInstr+1
	ld   [hli],a
	ld   a,$CB
	ld   [wInstr],a
	call TimeInstruction

	pop  hl
	ret


; Reports failed opcode
; L    -> opcode
; A    -> cycles it took
; (HL) -> cycles it should have taken
; Preserved: HL
PrintFailedOpcode:
	; Print opcode
	push af
	ld   a,l
	call PrintHex
	ld   a,':'
	call PrintChar
	pop  af

	; Print actual and correct times
	call PrintDec
	ld   a,'-'
	call PrintChar
	ld   a,[hl]
	call PrintDec
	ld   a,' '
	call PrintChar

	; Remember that failure occurred
	set_test 1

	ret


; Times instruction.
; HL -> address of byte just after instruction
; A  -> flags when executing instruction
; A  <- number of cycles instruction took
TimeInstruction:
	ld   c,a

	; Write JP InstrEnd to HL and wInstrAddr
	ld   a,$C3     ; JP
	ld   [hli],a
	ld   [wInstrAddr],a

	ld   a,LOW(InstrEnd)
	ld   [wInstrAddr+1],a
	ld   [hli],a

	ld   a,HIGH(InstrEnd)
	ld   [wInstrAddr+2],a
	ld   [hl],a

	; Save sp
	ld   [wSavedSp],sp

	; Set regs and stack contents
	push bc
	ld   bc,wInstrAddr
	ld   de,wInstrAddr
	ld   hl,wInstrAddr
	call StartTimer
	pop  af
	push hl

	; Environment instruction executes in:
	; 1 byte: OP
	; 2 byte: OP 00
	; 3 byte: OP wInstrAddr
	; BC,DE,HL = wInstrAddr
	; Stack has wInstrAddr pushed on it.
	; Stack pointer can be trashed by instr.
	; wInstrAddr contains JP InstrEnd, that
	; can be trashed. Instructions which trash
	; this don't execute it.

	jp   wInstr
InstrEnd:     ; instruction jumps here when done
	di

	; Restore sp
	ld   sp,wSavedSp
	pop  hl
	ld   sp,hl

	call StopTimer
	sub  24
	ret

; RST handlers
PUSHS
SECTION "vector 1", ROM0[$00]
	jp   InstrEnd
SECTION "vector 2", ROM0[$08]
	jp   InstrEnd
SECTION "vector 3", ROM0[$10]
	jp   InstrEnd
SECTION "vector 4", ROM0[$18]
	jp   InstrEnd
SECTION "vector 5", ROM0[$20]
	jp   InstrEnd
SECTION "vector 6", ROM0[$28]
	jp   InstrEnd
SECTION "vector 7", ROM0[$30]
	jp   InstrEnd
SECTION "vector 8", ROM0[$38]
	jp   InstrEnd
POPS

INCLUDE "shell_end.inc"

; Page-aligned tables (after the shell code, on the next 256-byte boundary)
DS ALIGN[8]

; Instruction lengths of opcodes.
; 0 for instructions not timed.
OpLens:
	db 1, 3, 1, 1, 1, 1, 2, 1, 3, 1, 1, 1, 1, 1, 2, 1 ; 0
	db 0, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1 ; 1
	db 2, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1 ; 2
	db 2, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1 ; 3
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; 4
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; 5
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; 6
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; 7
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; 8
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; 9
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; A
	db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ; B
	db 1, 1, 3, 3, 3, 1, 2, 1, 1, 1, 3, 0, 3, 3, 2, 1 ; C
	db 1, 1, 3, 0, 3, 1, 2, 1, 1, 1, 3, 0, 3, 0, 2, 1 ; D
	db 2, 1, 1, 0, 0, 1, 2, 1, 2, 1, 3, 0, 0, 0, 2, 1 ; E
	db 2, 1, 1, 1, 0, 1, 2, 1, 2, 1, 3, 1, 0, 0, 2, 1 ; F

; Timings for main opcodes
OpTimes:
	db 1, 3, 2, 2, 1, 1, 2, 1, 5, 2, 2, 2, 1, 1, 2, 1
	db 0, 3, 2, 2, 1, 1, 2, 1, 3, 2, 2, 2, 1, 1, 2, 1
	db 2, 3, 2, 2, 1, 1, 2, 1, 2, 2, 2, 2, 1, 1, 2, 1
	db 2, 3, 2, 2, 3, 3, 3, 1, 2, 2, 2, 2, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 2, 2, 2, 2, 2, 2, 0, 2, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 2, 3, 3, 4, 3, 4, 2, 4, 2, 4, 3, 0, 3, 6, 2, 4
	db 2, 3, 3, 0, 3, 4, 2, 4, 2, 4, 3, 0, 3, 0, 2, 4
	db 3, 3, 2, 0, 0, 4, 2, 4, 4, 1, 4, 0, 0, 0, 2, 4
	db 3, 3, 2, 1, 0, 4, 2, 4, 3, 2, 4, 1, 0, 0, 2, 4

; Timings when conditionals are taken
OpTimesTaken:
	db 1, 3, 2, 2, 1, 1, 2, 1, 5, 2, 2, 2, 1, 1, 2, 1
	db 0, 3, 2, 2, 1, 1, 2, 1, 3, 2, 2, 2, 1, 1, 2, 1
	db 3, 3, 2, 2, 1, 1, 2, 1, 3, 2, 2, 2, 1, 1, 2, 1
	db 3, 3, 2, 2, 3, 3, 3, 1, 3, 2, 2, 2, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 2, 2, 2, 2, 2, 2, 0, 2, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1
	db 5, 3, 4, 4, 6, 4, 2, 4, 5, 4, 4, 0, 6, 6, 2, 4
	db 5, 3, 4, 0, 6, 4, 2, 4, 5, 4, 4, 0, 6, 0, 2, 4
	db 3, 3, 2, 0, 0, 4, 2, 4, 4, 1, 4, 0, 0, 0, 2, 4
	db 3, 3, 2, 1, 0, 4, 2, 4, 3, 2, 4, 1, 0, 0, 2, 4

; Timings for CB-prefixed opcodes
CBOpTimes:
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2
	db 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2
	db 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2
	db 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2
	db 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2

ENDL
