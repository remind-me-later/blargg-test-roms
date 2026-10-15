; Driver of the multi-test ROM: runs the tests stored in the blocks of banks
; 1 and up, one after the other, and reports the first that failed.
;
; Reconstructed: the source of the driver was not part of the released
; sources. It was written to assemble to the code of the released ROM, and
; the names and comments are guessed.
;
; The driver runs from bank 0. A test is built with BUILD_MULTI and
; MULTI_TEST (its number) defined, which stores it in a block of $1000 bytes
; at $4000 + (MULTI_TEST & 3) * $1000 in bank 1 + MULTI_TEST / 4. To run it,
; the driver saves its state in the cartridge RAM, copies the block to $C000
; and jumps there; when the test exits, it jumps to $3F00, which restores the
; state and returns to the driver with the result of the test in A.

DEF MULTI_DRIVER EQU 1

INCLUDE "shell.inc"
INCLUDE "apu.s"
INCLUDE "cpu_speed.s"

; Variables
; In the same RAM as the variables of the tests: the driver saves them
; around each test (see below).
PUSHS UNION "Test HRAM variables", HRAM[hShellVariablesEnd]
hFirstFailed:   db      ; number of the first test that failed, or 0
hTestNumber:    db      ; number of the running test, from 0
POPS

; Cartridge RAM, where the state of the driver is kept while a test runs: SP,
; then the RAM from NV_RAM_START and HRAM, which the tests clear.
DEF STATE_SIZE EQU $9C
DEF DP_STATE_SIZE EQU 6

PUSHS "Saved state", SRAM[SAVED_STATE_START]
sSavedSp:       dw
sSavedState:    ds STATE_SIZE + DP_STATE_SIZE
POPS

; The way back from the tests, at a fixed address
PUSHS
SECTION "return from test", ROM0[$3F00]
     jp   TestExited
POPS

Reset:
     jp   StdReset

Main:
     ld   sp,$C000
     setb hFirstFailed,0
     setb hTestNumber,-1

.nextTest:
     lda  hTestNumber
     inc  a
     sta  hTestNumber

     ; Select the bank of the test, four to a bank
     srl  a
     srl  a
     inc  a
     ld   [rROMB],a

     ; DE = address of its block
     lda  hTestNumber
     swap a
     and  $30
     or   $40
     ld   d,a
     ld   e,0

     ; The blocks end at the first one that doesn't start with a JP
     ld   a,[de]
     cp   $C3
     jp   nz,.finished

     call PrintTestNumber
     call RunTest
     call ReportTest
     jp   .nextTest

.finished:
     call PrintNewline
     lda  hFirstFailed
     or   a
     jr   z,.allPassed
     call PrintNewline
     print_str "Run failed tests",NEWLINE
     print_str "individually for",NEWLINE
     print_str "more details.",NEWLINE

.allPassed:
     ; Beep
     call SoundOff
     call SoundOn
     wreg rAUD1LEN,$80
     wreg rAUD1ENV,$F1
     wreg rAUD1LOW,$00
     ld   c,5
.beep:
     wreg rAUD1HIGH,$87
     delay_msec 250
     dec  c
     jr   nz,.beep

     ; Exit with the number of the first test that failed
     lda  hFirstFailed
     ld   [wTestCode],a
     jp   TestsDone


; Runs the test whose block is at DE
RunTest:
     ; Save SP, as the test will use its own stack
     ld   hl,sp+0
     ld   a,l
     ld   [sSavedSp],a
     ld   a,h
     ld   [sSavedSp+1],a

     ; Save the variables of the driver
     push de
     ld   hl,sSavedState
     ld   bc,STATE_SIZE
     ld   de,NV_RAM_START
     call CopyBytes
     ld   bc,DP_STATE_SIZE
     ld   de,HRAM_START
     call CopyBytes
     pop  hl

     ; Copy the block and run it
     ld   c,$10
     jp   CopyToWRAMThenRun

     ; Back from the test at $3F00, with its result in A
TestExited:
     ld   d,a
     ld   a,[sSavedSp]
     ld   l,a
     ld   a,[sSavedSp+1]
     ld   h,a
     ld   sp,hl
     ld   a,d
     push af

     ; Restore the variables of the driver
     ld   de,sSavedState
     ld   bc,STATE_SIZE
     ld   hl,NV_RAM_START
     call CopyBytes
     ld   bc,DP_STATE_SIZE
     ld   hl,HRAM_START
     call CopyBytes

     call CPUNorm
     pop  af
     ret


; Copies BC bytes from DE to HL
CopyBytes:
     ld   a,[de]
     inc  de
     ld   [hli],a
     dec  bc
     ld   a,b
     or   c
     jr   nz,CopyBytes
     ret


; Prints the number of the test
PrintTestNumber:
     lda  hTestNumber
     inc  a
     call PrintDec2
     call ConsoleFlush
     ret


; Reports result A of the test: ok, or A in inverse. Remembers the first
; failure.
ReportTest:
     print_str ":"
     or   a
     jr   nz,.failed
     print_str "ok  "
     call ConsoleFlush
     ret

.failed:
     push af
     lda  hFirstFailed
     or   a
     jr   nz,.keepFirst
     lda  hTestNumber
     inc  a
     sta  hFirstFailed
.keepFirst:
     lda  hTestNumber
     inc  a
     call PlayByte
     ld   a,d
     call PlayByte
     call ConsoleInverse
     pop  af
     call PrintDec2
     call ConsoleNormal
     print_str "  "
     call ConsoleFlush
     ret

INCLUDE "shell_end.inc"
