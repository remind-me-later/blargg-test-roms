; Tests length and sweep periods, and synchronization between the two
DEF TEST_NAME EQUS "07-len sweep period sync"
INCLUDE "shell.inc"
INCLUDE "apu.s"

TestTiming:
     ; Time how long until next length clock
.wait:
     inc  de
     ld   a,[rAUDENA]
     and  $01
     jr   nz,.wait

     ;call     PrintDE

     ; Error if not in 0...4 range
     ld   a,d
     cp   0
     jp   nz,TestFailed
     ld   a,e
     cp   5
     jp   nc,TestFailed
     ret

Main:

     set_test 2,"Length period is wrong"
     call SyncAPU
     wreg rAUD1HIGH,$40  ; avoids extra length clock
     wreg rAUD1LEN,$3F  ; length = $01
     wreg rAUD1ENV,$08  ; silent without disabling channel
     wreg rAUD1HIGH,$C0  ; start length
     ld   de,-$170
     call TestTiming

     set_test 3,"Sweep period is wrong"
     call SyncSweep
     wreg rAUD1SWEEP,$10  ; sweep period = 1
     wreg rAUD1ENV,$08  ; silent without disabling channel
     wreg rAUD1LOW,$FF  ; max freq
     wreg rAUD1HIGH,$87  ; start
     ld   de,-$2E4
     call TestTiming

     set_test 4,"Sweep clock is synchronized with length"
     call SyncSweep
     wreg rAUD1HIGH,$40  ; avoids extra length clock
     wreg rAUD1LEN,$3F  ; length = $01
     wreg rAUD1ENV,$08  ; silent without disabling channel
     wreg rAUD1HIGH,$C0  ; start length
     ld   de,-$170
     call TestTiming

     set_test 5,"Powering up APU MODs next frame time with 8192"
     call SyncAPU
     ld   de,-$16F
     call TestPower

     call SyncAPU
     ld   de,-$B5
     call TestPowerOff

     call SyncAPU
     delay_clocks 8192
     ld   de,-$B5
     call TestPower

     call SyncAPU
     delay_clocks 8192
     ld   de,-$B5
     call TestPowerOff

     call SyncAPU
     ld   de,-$B5
     wreg rAUDENA,AUDENA_OFF  ; power off
     delay_clocks 8192
     call TestPower

     set_test 6,"Powering up APU resets 128 Hz sweep divider"
     call SyncSweep
     ld   de,-$229
     call TestPower2

     call SyncSweep
     delay_apu 1
     ld   de,-$229
     call TestPower2

     jp   TestsPassed

TestPowerOff:
     wreg rAUDENA,AUDENA_OFF  ; power off
TestPower:
     wreg rAUDENA,AUDENA_ON  ; power on
     wreg rAUD1HIGH,$40
     wreg rAUD1LEN,-1   ; length = 1
     wreg rAUD1ENV,8
     wreg rAUD1HIGH,$C0
     jp   TestTiming

TestPower2:
     wreg rAUDENA,AUDENA_OFF  ; power off
     wreg rAUDENA,AUDENA_ON  ; power on
     wreg rAUD1SWEEP,$11
     wreg rAUD1ENV,8
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$84
     jp   TestTiming

INCLUDE "shell_end.inc"
