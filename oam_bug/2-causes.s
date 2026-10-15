; Things that cause corruption

DEF TEST_NAME EQUS "2-causes"
INCLUDE "oam_bug.inc"

Main:
     save_sp

     set_test 2,"LD DE,$FE00 : INC DE"
     call Begin
     ld   de,$FE00
     inc  de
     call End

     set_test 3,"LD DE,$FE00 : DEC DE"
     call Begin
     ld   de,$FE00
     dec  de
     call End

     set_test 4,"LD DE,$FEFF : INC DE"
     call Begin
     ld   de,$FEFF
     inc  de
     call End

     set_test 5,"LD BC,$FE00 : INC BC"
     call Begin
     ld   bc,$FE00
     inc  bc
     call End

     set_test 6,"LD HL,$FE00 : INC HL"
     call Begin
     ld   hl,$FE00
     inc  hl
     call End

     set_test 7,"LD SP,$FE00 : INC SP"
     call Begin
     ld   sp,$FE00
     inc  sp
     restore_sp
     call End

     set_test 8,"LD SP,$FDFF : POP BC"
     call Begin
     ld   sp,$FDFF
     pop  bc
     restore_sp
     call End

     set_test 9,"LD SP,$FE00 : PUSH BC"
     call Begin
     ld   sp,$FE00
     push bc
     restore_sp
     call End

     set_test 10,"LD HL,$FE00 : LD A,(HL+)"
     call Begin
     ld   hl,$FE00
     ld   a,[hli]
     restore_sp
     call End

     set_test 11,"LD HL,$FE00 : LD A,(HL-)"
     call Begin
     ld   hl,$FE00
     ld   a,[hld]
     restore_sp
     call End

     jp   TestsPassed

Begin:
     call DisableLCD
     call FillOAM
     wreg rLCDC,LCDC_ON | LCDC_BG_ON
     delay 70224 - 6
     ret

End:
     call DisableLCD
     call CpOAM
     jp   z,TestFailed
     ret

INCLUDE "shell_end.inc"
