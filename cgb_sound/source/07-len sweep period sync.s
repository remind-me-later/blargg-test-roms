; Tests length and sweep periods, and synchronization between the two
DEF TEST_NAME EQUS "\"07-len sweep period sync\""
INCLUDE "shell.inc"
INCLUDE "apu.s"

test_timing:
     ; Time how long until next length clock
:    inc  de
     ld   a,[rAUDENA]
     and  $01
     jr   nz,:-

     ;call     print_de

     ; Error if not in 0...4 range
     ld   a,d
     cp   0
     jp   nz,test_failed
     ld   a,e
     cp   5
     jp   nc,test_failed
     ret

main:

     set_test 2,"Length period is wrong"
     call sync_apu
     wreg rAUD1HIGH,$40  ; avoids extra length clock
     wreg rAUD1LEN,$3F  ; length = $01
     wreg rAUD1ENV,$08  ; silent without disabling channel
     wreg rAUD1HIGH,$C0  ; start length
     ld   de,-$170
     call test_timing

     set_test 3,"Sweep period is wrong"
     call sync_sweep
     wreg rAUD1SWEEP,$10  ; sweep period = 1
     wreg rAUD1ENV,$08  ; silent without disabling channel
     wreg rAUD1LOW,$FF  ; max freq
     wreg rAUD1HIGH,$87  ; start
     ld   de,-$2E4
     call test_timing

     set_test 4,"Sweep clock is synchronized with length"
     call sync_sweep
     wreg rAUD1HIGH,$40  ; avoids extra length clock
     wreg rAUD1LEN,$3F  ; length = $01
     wreg rAUD1ENV,$08  ; silent without disabling channel
     wreg rAUD1HIGH,$C0  ; start length
     ld   de,-$170
     call test_timing

     set_test 5,"Powering up APU MODs next frame time with 8192"
     call sync_apu
     ld   de,-$16F
     call test_power

     call sync_apu
     ld   de,-$B5
     call test_power_off

     call sync_apu
     delay_clocks 8192
     ld   de,-$B5
     call test_power

     call sync_apu
     delay_clocks 8192
     ld   de,-$B5
     call test_power_off

     call sync_apu
     ld   de,-$B5
     wreg rAUDENA,AUDENA_OFF  ; power off
     delay_clocks 8192
     call test_power

     set_test 6,"Powering up APU resets 128 Hz sweep divider"
     call sync_sweep
     ld   de,-$229
     call test_power2

     call sync_sweep
     delay_apu 1
     ld   de,-$229
     call test_power2

     jp   tests_passed

test_power_off:
     wreg rAUDENA,AUDENA_OFF  ; power off
test_power:
     wreg rAUDENA,AUDENA_ON  ; power on
     wreg rAUD1HIGH,$40
     wreg rAUD1LEN,-1   ; length = 1
     wreg rAUD1ENV,8
     wreg rAUD1HIGH,$C0
     jp   test_timing

test_power2:
     wreg rAUDENA,AUDENA_OFF  ; power off
     wreg rAUDENA,AUDENA_ON  ; power on
     wreg rAUD1SWEEP,$11
     wreg rAUD1ENV,8
     wreg rAUD1LOW,$00
     wreg rAUD1HIGH,$84
     jp   test_timing

INCLUDE "shell_end.inc"
