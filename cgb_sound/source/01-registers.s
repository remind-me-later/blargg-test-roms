; - APU registers always have some bits set when read back.
; - Wave memory can be read back freely.
; - When powered off, registers are cleared, except high bit of NR52.
; - While off, register writes are ignored, but not reads.
; - Wave RAM is always readable and writable, and unaffected by power.

DEF TEST_NAME EQUS "01-registers"
INCLUDE "shell.inc"
INCLUDE "apu.s"

main:
     set_test 2,"NR10-NR51 and wave RAM write/read"
     ld   d,0
:    call test_rw
     inc  d
     jr   nz,:-

     set_test 3,"NR52 write/read"
     wreg rAUDENA,AUDENA_OFF
     lda  rAUDENA
     cp   $70
     jp   nz,test_failed
     wreg rAUDENA,$FF
     lda  rAUDENA
     cp   $F0
     jp   nz,test_failed

     set_test 4,"Powering APU shouldn't affect wave"
     ld   a,$37
     call fill_wave
     wreg rAUDENA,AUDENA_OFF

     ; Verify that wave RAM is unchanged
     ld   hl,AUD3WAVERAM
:    ld   a,[hli]
     cp   $37
     jp   nz,test_failed
     ld   a,l
     cp   $40
     jr   nz,:-
     wreg rAUDENA,AUDENA_ON ; on

     set_test 5,"Powering APU off should write 0 to all regs"
     ld   a,$FF
     call fill_apu_regs
     wreg rAUDENA,AUDENA_OFF
     wreg rAUDENA,AUDENA_ON
     call regs_should_be_clear

     set_test 6,"When off, should ignore writes to registers"
     wreg rAUDENA,AUDENA_OFF
     ld   a,$FF
     call fill_apu_regs
     wreg rAUDENA,AUDENA_ON
     call regs_should_be_clear
     wreg rAUDENA,AUDENA_ON

     set_test 7,"When off, should allow normal register reads"
     wreg rAUDENA,AUDENA_OFF
     call regs_should_be_clear
     wreg rAUDENA,AUDENA_ON

     jp   tests_passed

regs_should_be_clear:
     ld   bc,masks
     ld   hl,rAUD1SWEEP
:    ld   a,[bc]
     cp   [hl]
     jp   nz,test_failed
     inc  bc
     inc  l
     ld   a,l
     cp   LOW(rAUDENA)
     jr   nz,:-
     ret

test_rw:
     ld   bc,masks
     ld   hl,rAUD1SWEEP
:    ; Skip NR52
     ld   a,l
     cp   LOW(rAUDENA)
     jr   z,:+

     ; A = value that should be read back
     ld   a,[bc]
     or   d

     ; Write then read back and compare
     ld   [hl],d
     cp   [hl]
     jp   nz,test_failed

:    ; Mute channels
     wreg rAUDTERM,0

     ; Disable wave, in case it just got enabled
     ; while testing register
     wreg rAUD3ENA,0

     inc  bc
     inc  l
     ld   a,l
     cp   LOW(AUD3WAVERAM+AUD3WAVE_SIZE)
     jr   nz,:--
     ret

; Registers are ORed with this when reading
masks:
     db $80, $3F, $00, $FF, $BF ; NR10-NR15
     db $FF, $3F, $00, $FF, $BF ; NR20-NR25
     db $7F, $FF, $9F, $FF, $BF ; NR30-NR35
     db $FF, $FF, $00, $00, $BF ; NR40-NR45
     db $00, $00, $70         ; NR50-NR52
     db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
     db $00, $00, $00, $00, $00, $00, $00, $00 ; Wave RAM
     db $00, $00, $00, $00, $00, $00, $00, $00

INCLUDE "shell_end.inc"
