; Runs a test on each of the four channels.
;
; The test defines test_chan, which is called once per channel with the
; variables below describing the channel. wchn writes to its registers.
;
; Reconstructed: this file was not part of the released sources. It was
; written to assemble to the code in the released ROMs, and the names and
; comments are guessed.

INCLUDE "apu.s"

; Variables of the channel being tested
DEF chan = dp+0         ; 0 to 3
DEF chan_regs = dp+1    ; low byte of the address of its NRx0
DEF chan_mask = dp+2    ; its bit in NR52
DEF chan_maxlen = dp+3  ; its maximum length, mod 256
DEF dp = dp+4


; Writes data to register reg (0 to 4) of the channel being tested
; Preserved: BC, DE, HL
MACRO wchn ; reg, data
     lda  chan_regs
     add  \1
     ld   c,a
     ld   a,\2
     ld   [$FF00+c],a
ENDM


; Sets up the variables for channel n, which has its registers at NRx0 =
; regs, then calls test_chan with the DAC of the channel enabled and the
; channel off.
MACRO test_chan_n ; n, regs, mask, maxlen, dac register, dac value
     ld   a,\1
     sta  chan
     call print_dec
     call print_space
     wreg chan_regs,\2
     wreg chan_mask,\3
     wreg chan_maxlen,\4
     call console_flush
     wreg \5,\6
     call test_chan
ENDM


; Calls test_chan for every channel
MACRO test_all_chans
     test_chan_n 0,LOW(NR10),$01,$40,NR12,$08
     test_chan_n 1,LOW(NR10)+5,$02,$40,NR22,$08
     test_chan_n 2,LOW(NR10)+10,$04,$00,NR30,$80
     test_chan_n 3,LOW(NR10)+15,$08,$40,NR42,$08
ENDM
