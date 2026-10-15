; Runs a test on each of the four channels.
;
; The test defines TestChan, which is called once per channel with the
; variables below describing the channel. wchn writes to its registers.
;
; Reconstructed: this file was not part of the released sources. It was
; written to assemble to the code in the released ROMs, and the names and
; comments are guessed.

INCLUDE "apu.s"

; Variables of the channel being tested
; The variables of the tests, and of the driver of a multi-test ROM, share
; this section (and so, this RAM): the driver saves its own while a test runs.
PUSHS UNION "Test HRAM variables", HRAM[hShellVariablesEnd]
hChan:          db      ; 0 to 3
hChanRegs:      db      ; low byte of the address of its NRx0
hChanMask:      db      ; its bit in NR52
hChanMaxlen:    db      ; its maximum length, mod 256
POPS


; Writes data to register reg (0 to 4) of the channel being tested
; Preserved: BC, DE, HL
MACRO wchn ; reg, data
	lda  hChanRegs
	add  \1
	ld   c,a
	ld   a,\2
	ld   [$FF00+c],a
ENDM


; Sets up the variables for channel n, which has its registers at NRx0 =
; regs, then calls TestChan with the DAC of the channel enabled and the
; channel off.
MACRO test_chan_n ; n, regs, mask, maxlen, dac register, dac value
	ld   a,\1
	sta  hChan
	call PrintDec
	call PrintSpace
	wreg hChanRegs,\2
	wreg hChanMask,\3
	wreg hChanMaxlen,\4
	call ConsoleFlush
	wreg \5,\6
	call TestChan
ENDM


; Calls TestChan for every channel
MACRO test_all_chans
	test_chan_n 0,LOW(rAUD1SWEEP),$01,$40,rAUD1ENV,$08
	test_chan_n 1,LOW(rAUD1SWEEP)+5,$02,$40,rAUD2ENV,$08
	test_chan_n 2,LOW(rAUD1SWEEP)+10,$04,$00,rAUD3ENA,$80
	test_chan_n 3,LOW(rAUD1SWEEP)+15,$08,$40,rAUD4ENV,$08
ENDM
