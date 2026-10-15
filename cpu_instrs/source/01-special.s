; Tests instructions that don't fit template

DEF TEST_NAME EQUS "01-special"
INCLUDE "shell.inc"

main:
     set_test 2,"JR negative"
     ld   a,0
     jp   .jr_neg
     inc  a
.neg_target:
     inc  a
     inc  a
     cp   2
     jp   nz,test_failed
     jp   .neg_done
.jr_neg:
     jr   .neg_target
.neg_done:

     set_test 3,"JR positive"
     ld   a,0
     jr   .pos_target
     inc  a
.pos_target:
     inc  a
     inc  a
     cp   2
     jp   nz,test_failed


     set_test 4,"LD PC,HL"
     ld   hl,.hl_target
     ld   a,0
     jp   hl
     inc  a
.hl_target:
     inc  a
     inc  a
     cp   2
     jp   nz,test_failed


     set_test 5,"POP AF"
     ld   bc,$1200
.pop_af:
     push bc
     pop  af
     push af
     pop  de
     ld   a,c
     and  $F0
     cp   e
     jp   nz,test_failed
     inc  b
     inc  c
     jr   nz,.pop_af


     set_test 6,"DAA"
     ; Test all combinations of A and flags (256*16 total)
     ld   de,0
.daa:
     push de
     pop  af
     daa

     push af
     call update_crc
     pop  hl
     ld   a,l
     call update_crc

     inc  d
     jr   nz,.daa

     ld   a,e
     add  $10
     ld   e,a
     jr   nz,.daa

     check_crc $6A9F8D8A

     jp   tests_passed

INCLUDE "shell_end.inc"
