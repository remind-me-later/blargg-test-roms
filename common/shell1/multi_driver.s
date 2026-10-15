; Driver of the multi-test ROM: runs the tests stored in the blocks of banks
; 1 and up, one after the other, and reports how many failed.
;
; Reconstructed: the source of the driver was not part of the released
; sources. It was written to assemble to the code of the released ROM, and
; the names and comments are guessed.
;
; The driver runs from bank 0. A test is built with BUILD_MULTI and
; MULTI_TEST (its number) defined, which stores it in a block of $1000 bytes
; at $4000 + (MULTI_TEST & 3) * $1000 in bank 1 + MULTI_TEST / 4. To run it,
; the driver copies the block to $C000 and jumps there; when the test exits,
; it jumps to $3FFD, which comes back to the driver with its result in A.

DEF MULTI_DRIVER EQU 1

; The tests use the RAM at $D800 and $FF80: the driver keeps its variables
; below them.
DEF BSS_START EQU $D600
DEF HRAM_START EQU $FFC0

INCLUDE "shell.inc"
INCLUDE "apu.s"
INCLUDE "cpu_speed.s"

; The tests can leave SP anywhere, so the driver has a stack of its own and
; saves SP while a test runs.
DEF STACK_SIZE EQU $40

PUSHS "Driver variables", WRAMX[wShellVariablesEnd], BANK[1]
wStackBottom:   ds STACK_SIZE
wStackTop:
wSavedSp:       dw
POPS

; The tests' way back, at a fixed address
PUSHS
SECTION "return from test", ROM0[$3FFD]
	jp Main.testExited
POPS

Reset:
	jp StdReset

ReportByte:
	ret

Main:
	ld sp, wStackTop
	ld b, 0 ; test number
	ld c, 0 ; failed tests

.nextTest:
	; Select the bank of the test, four to a bank
	ld a, b
	srl a
	srl a
	inc a
	ld [rROMB], a

	; DE = address of its block
	ld a, b
	swap a
	and $30
	or $40
	ld d, a
	ld e, 0

	; The blocks end at the first one that doesn't start with a JP
	ld a, [de]
	cp $C3
	jp nz, .finished

	push bc
	call PrintTestNumber

	; Run it
	ld hl, sp+0
	ld a, l
	ld [wSavedSp], a
	ld a, h
	ld [wSavedSp+1], a
	ld h, d
	ld l, e
	jp CopyToWRAMThenRun

	; Back from the test at $3FFD, with its result in A
.testExited:
	ld d, a
	ld a, [wSavedSp]
	ld l, a
	ld a, [wSavedSp+1]
	ld h, a
	ld sp, hl
	ld a, d
	pop bc
	call ReportTest
	inc b
	jp .nextTest

.finished:
	call PrintNewline
	call PrintNewline
	ld a, c
	cp 0
	jr nz, .failed
	print_str "Passed all tests"
	jr .done

.failed:
	print_str "Failed "
	ld a, c
	call PrintDec
	print_str " tests."

.done:
	call PrintNewline

	; Beep
	call SoundOff
	call SoundOn
	wreg rAUD1LEN, $80
	wreg rAUD1ENV, $F1
	wreg rAUD1LOW, $00
	ld c, 10
.beep:
	wreg rAUD1HIGH, $87
	delay_msec 250
	dec c
	jr nz, .beep
.forever:
	jp .forever


; Prints number of test B
PrintTestNumber:
	ld a, b
	inc a
	call PrintDec2
	call ConsoleFlush
	ret


; Reports result A of test B: ok, or A in inverse. Counts the failure in C.
ReportTest:
	ld d, a
	call CPUNorm
	print_str ":"
	ld a, d
	cp 0
	jr nz, .failed
	print_str "ok  "
	call ConsoleFlush
	ret

.failed:
	inc c
	ld a, b
	call PlayByte
	ld a, d
	call PlayByte
	call ConsoleInverse
	ld a, d
	call PrintDec2
	call ConsoleNormal
	print_str "  "
	call ConsoleFlush
	ret

INCLUDE "shell_end.inc"
