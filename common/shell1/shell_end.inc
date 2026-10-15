; The shell code that goes after the program. RGBDS lays code out in source
; order, so it is in this file, which every program includes at its end.

IF DEF(BUILD_MULTI)

; A test of the multi-test ROM prints nothing and returns to the driver
init_runtime:
     ret

std_print:
     ret

post_exit:
     jp   MULTI_RETURN
forever:
     jr   forever

play_byte:
     ret

ELSE

INCLUDE "console.s"

init_runtime:
     call console_init
IF DEF(TEST_NAME)
     print_str "{TEST_NAME}",NEWLINE,NEWLINE
ENDC
     ret

std_print:
     push af
     sta  rSB
     wreg rSC,SC_START | SC_INTERNAL
     delay 2304
     pop  af
     jp   console_print

post_exit:
     call console_show
     call play_byte
forever:
     wreg rAUDENA,AUDENA_OFF    ; sound off
.loop:
     jr   .loop

play_byte:
     ret

ENDC

; Closes the block of the program, which runs from WRAM. The multi-test driver
; runs from ROM, and a test that has data to put after the shell code (see
; instr_timing) defines KEEP_PROGRAM_OPEN and closes the block itself.
IF !DEF(MULTI_DRIVER) && !DEF(KEEP_PROGRAM_OPEN)
     ENDL
ENDC
