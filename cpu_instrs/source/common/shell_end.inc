; The shell code that goes after the program (WLA-DX placed it there with
; `.section "runtime" returnOrg`). Included at the end of every program.

INCLUDE "console.s"

init_runtime:
     call console_init
IF DEF(TEST_NAME)
     print_str TEST_NAME,newline,newline
ENDC
     ret

std_print:
     push af
     sta  SB
     wreg SC,$81
     delay 2304
     pop  af
     jp   console_print

post_exit:
     call console_show
     call play_byte
forever:
     wreg NR52,0    ; sound off
:    jr   :-

play_byte:
     ret
