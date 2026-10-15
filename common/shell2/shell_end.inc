; The shell code that goes after the program. RGBDS lays code out in source
; order, so it is in this file, which every program includes at its end.

     ; Catch user code running off end
     jp   internal_error

; Common routines
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
IF DEF(CHECK_GB_ID)
     ; Keep only the values that the boot ROMs of the DMG and CGB leave in A
     ld   b,a
     and  $EA
     jr   z,:+
     ld   b,0
:    ld   a,b
ENDC
     ld   [gb_id],a

     ; Clear memory except very top of stack
     ld   bc,std_stack-bss_base - 2
     ld   hl,bss_base
     call clear_mem
     ld   bc,$FFFF-dp_base
     ld   hl,dp_base
     call clear_mem

     ; Init hardware
     wreg rTAC,$00
     wreg rIF,$00
     wreg rIE,$00

     wreg rAUDENA,AUDENA_OFF    ; sound off
     wreg rAUDENA,AUDENA_ON  ; sound on
     wreg rAUDTERM,$FF  ; mono
     wreg rAUDVOL,$77  ; volume

     call init_runtime
     call init_text_out
     call console_init
     call init_testing

     IF DEF(TEST_NAME)
          print_str "{TEST_NAME}",newline,newline
     ENDC

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
     call console_show
     pop  af
     call play_byte
     jp   post_exit

:    push af
     call print_newline
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


; Clears BC bytes starting at HL
clear_mem:
     ; If C>0, increment B
     dec  bc
     inc  c
     inc  b

     ld   a,0
:    ld   [hli],a
     dec  c
     jr   nz,:-
     dec  b
     jr   nz,:-
     ret


; Reports internal error and exits with code 255
internal_error:
     print_str "Internal error"
     ld   a,255
     jp   exit


; build_devcart and build_multi customize this
IF !DEF(CUSTOM_PRINT)

     ; Initializes text output to cartridge RAM
     init_text_out:
          ; Enable cartridge RAM and set text output pointer
          setb rRAMG,RAMG_SRAM_ENABLE
          setw text_out_addr,text_out_base
          setb text_out_base-3,$DE
          setb text_out_base-2,$B0
          setb text_out_base-1,$61
          setb text_out_base,0
          setb final_result,$80
          ret


     ; Appends character to text output string
     ; Preserved: AF, BC, DE, HL
     write_text_out:
          push hl
          push af
          ld   a,[text_out_addr]
          ld   l,a
          ld   a,[text_out_addr+1]
          ld   h,a
          inc  hl
          ld   [hl],0
          ld   a,l
          ld   [text_out_addr],a
          ld   a,h
          ld   [text_out_addr+1],a
          dec  hl
          pop  af
          ld   [hl],a
          pop  hl
          ret

     print_char_nocrc:
          call write_text_out
          jp   console_print
ENDC


; only build_rom uses console
IF DEF(NEED_CONSOLE)
     INCLUDE "console.s"
ELSE
     console_init:
     console_print:
     console_flush:
     console_normal:
     console_inverse:
     console_show:
     console_set_mode:
          ret
ENDC


; build_devcart and build_multi need to customize this
IF !DEF(CUSTOM_EXIT)
     post_exit:
          ld   [final_result],a
     forever:
          wreg rAUDENA,AUDENA_OFF    ; sound off
:         jr   :-
ENDC

IF DEF(BUILD_MULTI)

; A test of the multi-test ROM prints nothing and returns to the driver
init_runtime:
     ret

init_text_out:
     ret

print_char_nocrc:
     ret

play_byte:
     ret

post_exit:
     jp   MULTI_RETURN

ELSE

init_runtime:
     ret

play_byte:
     ret

ENDC

; Closes the block of the program, which runs from WRAM. The multi-test driver
; runs from ROM, and a test that has data to put after the shell code (see
; instr_timing) defines KEEP_PROGRAM_OPEN and closes the block itself.
IF !DEF(MULTI_DRIVER) && !DEF(KEEP_PROGRAM_OPEN)
     ENDL
ENDC
