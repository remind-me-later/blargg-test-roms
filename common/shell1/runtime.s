; Common routines and runtime

; Must be defined by target-specific runtime:
;
; InitRuntime:     ; target-specific inits
; StdPrint:        ; default routine to print char A
; PostExit:        ; called at end of std_exit
; ReportByte:      ; report A to user

INCLUDE "variables.inc"

; DMG/CGB hardware identifier, wGbId
DEF GB_ID_CGB EQU $10  ; mask for testing CGB bit
DEF GB_ID_DEVCART EQU $04 ; mask for testing "on devcart" bit

; Stack is normally here
DEF STD_STACK EQU $DFFF

; Copies $1000 bytes from HL to $C000, then jumps to it.
; A is preserved for jumped-to code.
IF !DEF(BUILD_MULTI)

SECTION "copy to WRAM", ROM0[$200]
CopyToWRAMThenRun:
     ld   b,a

     ld   de,$C000
     ld   c,$10
.copy:
     ld   a,[hli]
     ld   [de],a
     inc  e
     jr   nz,.copy
     inc  d
     dec  c
     jr   nz,.copy

     ld   a,b
     jp   $C000

IF !DEF(MULTI_DRIVER)

Reset:
     ; Run code from $C000, as is done on devcart. This
     ; ensures minimal difference in how it behaves.
     ld   hl,$4000
     jp   CopyToWRAMThenRun

; The program: stored in bank 1, assembled for and run from $C000.
SECTION "program", ROMX[$4000], BANK[1]
LOAD "program in WRAM", WRAM0[$C000]
     jp   StdReset

ENDC

ELSE

; One of the tests of the multi-test ROM, stored in its own block.
SECTION "multi test {MULTI_TEST}", ROMX[$4000 + (MULTI_TEST % 4) * $1000], BANK[1 + MULTI_TEST / 4]
LOAD UNION "multi test in WRAM", WRAM0[$C000]
     jp   StdReset

ENDC

; Common routines
INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "delay.s"
INCLUDE "crc.s"
INCLUDE "printing.s"
INCLUDE "numbers.s"
INCLUDE "testing.s"

; Sets up hardware and runs Main
StdReset:

     ; Init hardware
     di
     ld   sp,STD_STACK

     ; Save DMG/CGB id
     ld   [wGbId],a

     ; Init hardware
     wreg rTAC,$00
     wreg rIF,$00
     wreg rIE,$00

     wreg rAUDENA,AUDENA_OFF    ; sound off
     wreg rAUDENA,AUDENA_ON  ; sound on
     wreg rAUDTERM,$FF  ; mono
     wreg rAUDVOL,$77  ; volume

     ; TODO: clear all memory?

     ld   hl,StdPrint
     call InitPrinting
     call InitTesting
     call InitRuntime
     call ResetCRC ; in case InitRuntime prints anything

     delay_msec 250

     ; Run user code
     call Main

     ; Default is to successful exit
     ld   a,0
     jp   Exit


; Exits code and reports value of A
Exit:
     ld   sp,STD_STACK
     push af
     call .report
     pop  af
     jp   PostExit

.report:
     push af
     call PrintNewline
     call ShowPrinting
     pop  af

     ; Report exit status
     cp   1

     ; 0: ""
     ret  c

     ; 1: "Failed"
     jr   nz,.failedN
     print_str "Failed",NEWLINE
     ret

     ; n: "Failed #n"
.failedN:
     print_str "Failed #"
     call PrintDec
     call PrintNewline
     ret

; The rest of the shell is in shell_end.inc, after the user code.
