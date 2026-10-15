; Sound chip utilities

; Turns APU off
; Preserved: BC, DE, HL
SoundOff:
	wreg rAUDENA,AUDENA_OFF
	ret


; Turns APU on
; Preserved: BC, DE, HL
SoundOn:
	wreg rAUDENA,AUDENA_ON  ; power
	wreg rAUDTERM,$FF  ; mono
	wreg rAUDVOL,$77  ; volume
	ret


; Synchronizes to APU length counter within
; tens of clocks. Uses square 2 channel.
; Preserved: BC, DE, HL
SyncAPU:
	wreg rAUD2HIGH,$00  ; disable length
	wreg rAUD2LEN,$3E  ; length = 2 (in case of extra len clk)
	wreg rAUD2ENV,$08  ; silent without disabling channel
	wreg rAUD2HIGH,$C0  ; start length
.wait:
	lda  rAUDENA      ; wait for length to reach zero
	and  $02
	jr   nz,.wait
	ret


; Synchronizes to first square sweep within
; tens of clocks. Uses square 1 channel.
; Preserved: BC, DE, HL
SyncSweep:
	wreg rAUD1SWEEP,$11  ; sweep period = 1, shift = 1
	wreg rAUD1ENV,$08  ; silent without disabling channel
	wreg rAUD1LOW,$FF  ; freq = $3FF
	wreg rAUD1HIGH,$83  ; start
.wait:
	lda  rAUDENA
	and  $01
	jr   nz,.wait
	ret


; Copies 16-byte wave from (HL) to wave RAM
; Preserved: BC, DE
LoadWave:
	push bc
	wreg rAUD3ENA,$00  ; disable while writing
	ld   c,$30
.copy:
	ld   a,[hli]
	ld   [$FF00+c],a
	inc  c
	bit  6,c
	jr   z,.copy
	pop  bc
	ret


; Makes short beep
; Preserved: BC, DE, HL
Beep:
	xor  a         ; sound off
	sta  rAUDENA
	dec  a
	sta  rAUDENA      ; sound on
	sta  rAUDTERM      ; mono
	sta  rAUDVOL      ; volume
	wreg rAUD1ENV,$F1  ; volume, envelope rate
	wreg rAUD1HIGH,$86  ; note on, pitch
	delay_msec 250
	ret


; Marks sound with bits of A encoded into volume
; Preserved: BC, DE, HL
MarkSound:
	push bc
	ld   c,a
	ld   b,8
	wreg rAUD1SWEEP,0
	wreg rAUD1LEN,$80
	wreg rAUD1LOW,$F8
.nextBit:
	ld   a,$60
	rl   c
	jr   nc,.setVolume
	ld   a,$A0
.setVolume:
	sta  rAUD1ENV
	wreg rAUD1HIGH,$87
	delay_usec 300
	wreg rAUD1ENV,0
	delay_usec 100
	dec  b
	jr   nz,.nextBit
	pop  bc
	ret


; Fills wave RAM with A
; Preserved: BC, DE, HL
FillWave:
	push bc
	ld   c,$30
.fill:
	ld   [$FF00+c],a
	inc  c
	bit  6,c
	jr   z,.fill
	pop  bc
	ret


; Gets current length counter value for
; channel with mask A into A. Length counter
; must be enabled for that channel.
; Preserved: BC, DE, HL
GetLenA:
	push bc
	ld   c,a
	ld   b,0
.count:
	lda  rAUDENA      ; 3
	and  c         ; 1
	jr   z,.done    ; 2
	delay 4096-10
	inc  b         ; 1
	jr   nz,.count  ; 3
.done:
	ld   a,b
	pop  bc
	ret


; Synchronizes exactly to length clock. Next length clock
; occurs by 4079 clocks after this returns. Uses NR2x.
; Preserved: AF, BC, DE, HL
SyncLength:
	push af
	push hl

	ld   hl,rAUDENA
	wreg rAUD2ENV,$08  ; silent without disabling channel
	wreg rAUD2HIGH,$40  ; avoids extra length clock on trigger
	wreg rAUD2LEN,-2   ; length = 2, in case clock occurs immediately
	wreg rAUD2HIGH,$C0  ; start length

	; Coarse sync
	ld   a,$02
.coarse:
	and  [hl]
	jr   nz,.coarse

	; Fine sync. Slowly moves "forward" until
	; length clock occurs just before reading NR52.
.fine:
	delay 4097-20
	wreg rAUD2LEN,-1   ; 5
	wreg rAUD2HIGH,$C0  ; 5
	lda  rAUDENA      ; 3
	delay 2        ; 2
	and  $02       ; 2
	jr   nz,.fine   ; 3

	pop  hl
	pop  af
	ret


; Delays n*4096 cycles
; Preserved: BC, DE, HL
MACRO delay_frames ; n
	ld   a,\1
	call DelayFrames_
ENDM


; Delays A*4096+13 cycles (including CALL)
; Preserved: BC, DE, HL
DelayAFrames:
	or   a              ; 1
	jr   nz,DelayFrames_.loop ; 3
					; -1
	ret
DelayFrames_:           ; delays 4096*A-2 cycles (including CALL)
	push af             ; 4
	ld   a,256-13-20-12 ; 2
	jr   .delay           ; 3
.loop:
	push af             ; 4
	ld   a,256-13-20    ; 2
.delay:
	call DelayA20Cycles
	delay 4096-256
	pop  af             ; 3
	dec  a              ; 1
	jr   nz,.loop         ; 3
					; -1
	ret


MACRO test_chan_timing ; chan, iter
	ld   a,\1
	call PrintDec
	call PrintSpace
	ld   a,\2
.loop\@:
	push af
	TestChan 1<<\1, \1*5+rAUD1SWEEP
	pop  af
	dec  a
	jr   nz,.loop\@
	call PrintNewline
ENDM

MACRO test_chans
	test_chan_timing 0,\1
	test_chan_timing 1,\1
	test_chan_timing 2,\1
	test_chan_timing 3,\1
ENDM
