; Tests DI, EI, and HALT (STOP proved untestable)

DEF TEST_NAME EQUS "\"02-interrupts\""
INCLUDE "shell.inc"

main:
     wreg IE,$04
     
     set_test 2,"EI"
     ei
     ld   bc,0
     push bc
     pop  bc
     inc  b
     wreg rIF,$04
interrupt_addr:
     dec  b
     jp   nz,test_failed
     ld   hl,sp-2
     ld   a,[hli]
     cp   LOW(interrupt_addr)
     jp   nz,test_failed
     ld   a,[hl]
     cp   HIGH(interrupt_addr)
     jp   nz,test_failed
     lda  rIF
     and  $04
     jp   nz,test_failed
     
     set_test 3,"DI"
     di
     ld   bc,0
     push bc
     pop  bc
     wreg rIF,$04
     ld   hl,sp-2
     ld   a,[hli]
     or   [hl]
     jp   nz,test_failed
     lda  rIF
     and  $04
     jp   z,test_failed
     
     set_test 4,"Timer doesn't work"
     wreg TAC,$05
     wreg TIMA,0
     wreg rIF,0
     delay 500
     lda  rIF
     delay 500
     and  $04
     jp   nz,test_failed
     delay 500
     lda  rIF
     and  $04
     jp   z,test_failed
     pop  af
     
     set_test 5,"HALT"
     wreg TAC,$05
     wreg TIMA,0
     wreg rIF,0
     halt      ; timer interrupt will exit halt
     nop       ; avoids DMG bug
     lda  rIF
     and  $04
     jp   z,test_failed
     
     jp   tests_passed

; The multi-test ROM has this vector already, from test 07
IF !DEF(BUILD_MULTI)
PUSHS
SECTION "vector 1", ROM0[$50]
     inc a
     ret
POPS
ENDC

INCLUDE "shell_end.inc"
