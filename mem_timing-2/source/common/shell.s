; Common routines and runtime

; A few bytes of RAM that aren't cleared
DEF nv_ram_base = $D800
DEF nv_ram = nv_ram_base

; Address of next normal variable
DEF bss_base = nv_ram_base+$80
DEF bss = bss_base

; Address of next direct-page ($FFxx) variable
DEF dp_base = $FF80
DEF dp = dp_base

; Top of stack
DEF std_stack = $DFFF+1

; Final exit result byte is written here
DEF final_result = $A000

; Text output is written here as zero-terminated string
DEF text_out_base = $A004

; DMG/CGB hardware identifier
DEF gb_id_cgb = $10 ; mask for testing CGB bit
DEF gb_id_devcart = $04 ; mask for testing "on devcart" bit
DEF gb_id = nv_ram
DEF nv_ram = nv_ram+1

; The program is stored in ROM bank 1 and run from $C000, as is done on devcart.
; Bank 0 holds the header, the vectors and this routine, which copies it.
IF !DEF(BUILD_MULTI)

; Copies C*$100 bytes from HL to $C000, then jumps to it.
; A is preserved for jumped-to code.
SECTION "copy to WRAM", ROM0[$2150]
copy_to_wram_then_run:
     ld   b,a

     ld   de,$C000
:    ld   a,[hli]
     ld   [de],a
     inc  e
     jr   nz,:-
     inc  d
     dec  c
     jr   nz,:-

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

; build_devcart and build_multi customize this
IF !DEF(CUSTOM_PRINT)
DEF text_out_addr = bss+0
DEF bss = bss+2
ENDC

INCLUDE "console.inc"
