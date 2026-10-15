; Common routines and runtime

; Must be defined by target-specific runtime:
;
; init_runtime:     ; target-specific inits
; std_print:        ; default routine to print char A
; post_exit:        ; called at end of std_exit
; report_byte:      ; report A to user

DEF RUNTIME_INCLUDED = 1

IF !DEF(bss)
     ; address of next normal variable
     DEF bss = $D800
ENDC

IF !DEF(dp)
     ; address of next direct-page ($FFxx) variable
     DEF dp = $FF80
ENDC

; DMG/CGB hardware identifier
DEF gb_id_cgb = $10  ; mask for testing CGB bit
DEF gb_id_devcart = $04 ; mask for testing "on devcart" bit

DEF gb_id = bss
DEF bss = bss+1

; Stack is normally here
DEF std_stack = $DFFF

; Copies $1000 bytes from HL to $C000, then jumps to it.
; A is preserved for jumped-to code.
IF !DEF(BUILD_MULTI)

SECTION "copy to WRAM", ROM0[$200]
copy_to_wram_then_run:
     ld   b,a
     
     ld   de,$C000
     ld   c,$10
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
     ; Run code from $C000, as is done on devcart. This
     ; ensures minimal difference in how it behaves.
     ld   hl,$4000
     jp   copy_to_wram_then_run

; The program: stored in bank 1, assembled for and run from $C000.
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

; Common routines
INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "delay.s"
INCLUDE "crc.s"
INCLUDE "printing.s"
INCLUDE "numbers.s"
INCLUDE "testing.s"
     
; Sets up hardware and runs main
std_reset:

     ; Init hardware
     di
     ld   sp,std_stack
     
     ; Save DMG/CGB id
     ld   [gb_id],a
     
     ; Init hardware
     wreg rTAC,$00
     wreg rIF,$00
     wreg rIE,$00
     
     wreg rAUDENA,AUDENA_OFF    ; sound off
     wreg rAUDENA,AUDENA_ON  ; sound on
     wreg rAUDTERM,$FF  ; mono
     wreg rAUDVOL,$77  ; volume
     
     ; TODO: clear all memory?
     
     ld   hl,std_print
     call init_printing
     call init_testing
     call init_runtime
     call reset_crc ; in case init_runtime prints anything
     
     delay_msec 250
     
     ; Run user code
     call main
     
     ; Default is to successful exit
     ld   a,0
     jp   exit


; Exits code and reports value of A
exit:
     ld   sp,std_stack
     push af
     call :+
     pop  af
     jp   post_exit

:    push af
     call print_newline
     call show_printing
     pop  af
     
     ; Report exit status
     cp   1
     
     ; 0: ""
     ret  c
     
     ; 1: "Failed"
     jr   nz,:+
     print_str "Failed",newline
     ret
     
     ; n: "Failed #n"
:    print_str "Failed #"
     call print_dec
     call print_newline
     ret

; The rest of the shell is in shell_end.inc, after the user code.
