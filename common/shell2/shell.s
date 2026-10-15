; Common routines and runtime

; Where the variables are, see variables.inc
DEF NV_RAM_START EQU $D800              ; a few bytes of RAM that aren't cleared
DEF BSS_START EQU NV_RAM_START+$80      ; normal variables, cleared at reset
DEF HRAM_START EQU $FF80                ; HRAM ($FFxx) variables, cleared at reset

; Top of stack
DEF STD_STACK EQU $DFFF+1

; DMG/CGB hardware identifier (wGbId)
DEF GB_ID_CGB EQU $10 ; mask for testing CGB bit
DEF GB_ID_DEVCART EQU $04 ; mask for testing "on devcart" bit

; The program is stored in ROM bank 1 and run from $C000, as is done on devcart.
; Bank 0 holds the header, the vectors and this routine, which copies it.
IF !DEF(BUILD_MULTI)

; Copies C*$100 bytes from HL to $C000, then jumps to it.
; A is preserved for jumped-to code.
SECTION "copy to WRAM", ROM0[$2150]
copy_to_wram_then_run:
     ld   b,a

     ld   de,$C000
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

reset:
     di

     ; Run code from $C000, as is done on devcart. This
     ; ensures minimal difference in how it behaves.
     ld   hl,$4000
     ld   c,$14
     jp   copy_to_wram_then_run

; The program, assembled for $C000. The code of the libraries (the .s files)
; is in shell_end.inc, because it has to follow the program.
SECTION "program", ROMX[$4000], BANK[1]
LOAD "program in WRAM", WRAM0[$C000]
     jp   std_reset

ENDC

ELSE

; One of the tests of the multi-test ROM, stored in its own block.
SECTION "multi test {MULTI_TEST}", ROMX[$4000 + (MULTI_TEST % 4) * $1000], BANK[1 + MULTI_TEST / 4]
LOAD UNION "multi test in WRAM", WRAM0[$C000]
     jp   std_reset

ENDC

; Definitions and macros of the libraries
INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "delay.inc"
INCLUDE "crc.inc"
INCLUDE "printing.inc"
INCLUDE "numbers.inc"
INCLUDE "testing.inc"

INCLUDE "console.inc"
INCLUDE "variables.inc"
