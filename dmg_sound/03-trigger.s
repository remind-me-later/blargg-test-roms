; Verifies length counter clocking during fifth register writes

;DEF CGB_02 EQU 1
DEF TEST_NAME EQUS "03-trigger"
INCLUDE "shell.inc"
INCLUDE "test_chan.s"

Main:
     test_all_chans
     jp   TestsPassed

Begin:
     call SyncAPU
     wchn 1,-60
     wchn 4,$80
     ret

End:
     delay_clocks 8192+1024 ; so we don't clock length when enabling it below
EndNoDelay:
     ld   b,a
     wchn 4,$C0
     ld   a,b
EndPassive:
     ld   b,a
     lda  hChanMask
     call GetLenA
     cp   b
     jp   nz,TestFailed
     ret

TestChan:
     set_test 2,"Enabling in second half of length period ","shouldn't clock length"
     call Begin
     wchn 1,-2      ; length = 2
     delay_clocks 8256 ; delay until beginning of second half of length period
     wchn 4,$40     ; enable
     ld   a,2
     call EndNoDelay

     set_test 3,"Enabling in first half of length period should clock length"
     call Begin
     wchn 1,-2      ; length = 2
     delay_clocks 7900 ; delay until near-end of first half of length period
     wchn 4,$40     ; enable
     ld   a,1
     call EndNoDelay

IF DEF(CGB_02)
     set_test 4,"Keeping disabled should clock length; ","disabling or keeping enabled shouldn't"
     call Begin
     wchn 1,-2      ; length = 2
     wchn 4,$00     ; disabled -> disabled clocks as well
     ld   a,1
     call End

     call Begin
     wchn 4,$40     ; enable length
     wchn 1,-2      ; length = 2
     wchn 4,$40     ; enabled  -> enabled  doesn't clock
     wchn 4,$00     ; enabled  -> disabled doesn't clock
     ld   a,2
     call End
ELSE
     set_test 4,"Anything besides enabling shouldnt't clock"
     call Begin
     wchn 4,$40     ; enable length
     wchn 1,-2      ; length = 2
     wchn 4,$40     ; enabled  -> enabled  doesn't clock
     wchn 4,$00     ; enabled  -> disabled doesn't clock
     wchn 4,$00     ; disabled -> disabled doesn't clock
     ld   a,2
     call End
ENDC

     set_test 5,"If clock makes length zero, should disable chan"
     call Begin
     wchn 1,-1      ; length = 1
     wchn 4,$40     ; enable, causing clock to zero
     lda  hChanMask
     ld   b,a
     lda  rAUDENA      ; channel now disabled
     and  b
     jp   nz,TestFailed

     set_test 6,"If length already reached zero, shouldn't clock"
     call Begin
     wchn 1,-1      ; length = 1
     wchn 4,$40     ; enable, causing clock to zero
     wchn 4,0
     wchn 4,$40     ; no clock; length still 0
     wchn 4,0
     wchn 4,$40     ; no clock; length still 0
     lda  hChanMaxlen ; end triggers channel, which loads it with max length
     call End

     set_test 7,"Trigger should un-freeze length that reached zero"
     call Begin
     wchn 1,-1      ; length = 1
     wchn 4,$40     ; enable, causing clock to zero
     wchn 4,$00     ; disable
     wchn 4,$80     ; trigger unfreezes length, so it takes on maximum value
     delay_clocks 8192
     wchn 4,$40     ; enable
     delay_apu 2    ; clock length by 2
     lda  hChanMaxlen
     sub  2
     call EndNoDelay

     set_test 8,"Trigger that un-freezes enabled length should clock it"
     call Begin
     wchn 1,-1      ; length = 1
     wchn 4,$40     ; enable, causing clock to zero
     wchn 4,$00     ; disable
     wchn 4,$C0     ; trigger unfreezes length, and since enabled, clocks it
     lda  hChanMaxlen
     dec  a
     call EndNoDelay

     call Begin
     wchn 1,-1      ; length = 1
     wchn 4,$40     ; enable, causing clock to zero
     wchn 4,$C0     ; trigger unfreezes length, and since enabled, clocks it
     lda  hChanMaxlen
     dec  a
     call EndNoDelay

     set_test 9,"Triggering that clocks length of 1 ","should clock twice and shouldn't freeze"
     call Begin
     wchn 1,-1      ; length = 1
     wchn 4,$C0     ; trigger and enable
                    ; First length counter is enabled, which clocks it to 0 and freezes it
                    ; Trigger unfreezes length counter, which clocks it AGAIN
                    ; The result is the same as the previous test, which enables separately
     lda  hChanMaxlen
     dec  a
     call EndNoDelay

     set_test 10,"Trigger shouldn't otherwise affect length"
     call Begin
     wchn 1,0       ; length = max
     delay_clocks 8192
     wchn 4,$80     ; trigger
     lda  hChanMaxlen
     call EndNoDelay

IF !DEF(CGB_02)
     call Begin
     wchn 1,0       ; length = max
     wchn 4,$80     ; trigger
     lda  hChanMaxlen
     call End

     call Begin
     wchn 1,-2      ; length = 2
     wchn 4,$80     ; trigger
     ld   a,2
     call End
ENDC

     set_test 11,"Disabled DAC shouldn't stop other trigger effects"
     call Begin
     wchn 0,$00     ; disable wave DAC
     wchn 2,$07     ; disable square/noise DAC
     wchn 1,-1
     wchn 4,$C0     ; clocks length, which becomes max
     wchn 0,$80     ; enable wave DAC
     wchn 2,$08     ; enable square/noise DAC
     wchn 4,$80     ; trigger
     lda  hChanMaxlen
     dec  a
     call End

     set_test 12,"Other trigger effects should still occur when disabled"
     call SyncAPU
     wchn 0,0
     wchn 4,0
     wchn 1,-1
     wchn 4,$40     ; len = 0
     wchn 4,0
     wchn 4,$40     ; len = 0
     wchn 4,$80     ; len = max
     wchn 4,$40     ; len = max-1
     wchn 4,0
     wchn 4,$40     ; len = max-2
     wchn 0,$80     ; enable now
     wchn 4,$C0
     lda  hChanMaxlen
     sub  3
     call DelayAPUCycles
     lda  hChanMask
     ld   b,a
     lda  rAUDENA
     and  b
     jp   z,TestFailed
     delay_apu 1
     lda  rAUDENA
     and  b
     jp   nz,TestFailed

     ret

INCLUDE "shell_end.inc"
