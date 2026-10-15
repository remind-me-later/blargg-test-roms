; Sound chip utilities
;
; Reconstructed: this file was not part of the released sources. It was
; written to assemble to the code that precedes the tests in the released
; ROMs, and the names and comments are guessed.

; Delays n*4096 cycles, the period of the length counter.
; Preserved: AF, BC, DE, HL
MACRO delay_apu
     delay (\1)*4096
ENDM


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


; Synchronizes to APU length counter within tens of clocks.
; Uses square 2 channel.
; Preserved: AF, BC, DE, HL
SyncAPUCoarse:
     push af
     push hl
     wreg rAUD2ENV,$08  ; silent without disabling channel
     wreg rAUD2LEN,-3   ; length = 3
     wreg rAUD2HIGH,$C0  ; start length
     ld   hl,rAUDENA
     wreg rAUD2LEN,-1   ; length = 1
     ld   a,$02
.wait:
     and  [hl]      ; wait for length to reach zero
     jr   nz,.wait
     pop  hl
     pop  af
     ret


; Synchronizes to APU length counter exactly. Uses square 2 channel.
; Preserved: AF, BC, DE, HL
SyncAPU:
     call SyncAPUCoarse
     push af
     push hl

     wreg rAUD2LEN,-1   ; length = 1
     wreg rAUD2HIGH,$C0  ; start length
     delay 4057
     ld   hl,rAUDENA
     ld   a,[hl]    ; read status twice in a row
     ld   h,[hl]
     bit  1,a
     ; The conditional jumps to the next instruction in this routine are
     ; there for their timing: taken or not, they end up in the same place.
     jr   nz,.next
.next:
     ld   a,h
     rra
     rra

     wreg rAUD2LEN,-1   ; length = 1
     wreg rAUD2HIGH,$C0  ; start length
     delay 4072
     ld   hl,rAUDENA
     ld   a,[hl]
     ld   h,[hl]
     jr   c,.next2
.next2:
     bit  1,h
     jr   nz,.next3
.next3:
     rra
     rra
     jr   c,.next4
.next4:
     pop  hl
     pop  af
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


; Fills wave RAM with A
; Preserved: BC, DE, HL
FillWave:
     push bc
     ld   bc,$1030
.fill:
     ld   [$FF00+c],a
     inc  c
     dec  b
     jr   nz,.fill
     pop  bc
     ret


; Fills NR10-NR2F with A
; Preserved: BC, DE, HL
FillAPURegs:
     push bc
     ld   bc,$2010
.fill:
     ld   [$FF00+c],a
     inc  c
     dec  b
     jr   nz,.fill
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
     jr   z,.done   ; 2
     delay 4096-10
     inc  b         ; 1
     jr   nz,.count ; 3
.done:
     ld   a,b
     pop  bc
     ret


; Delays A*4096 cycles
; Preserved: BC, DE, HL
DelayAPUCycles:
     or   a
     ret  z
.loop:
     delay 4096-4
     dec  a         ; 1
     jr   nz,.loop  ; 3
     ret


; Counts into B the length clocks that channel A (0 to 3) takes to turn off,
; timing them with the length counter of the wave channel, or of square 2
; for the wave channel. Carry is set if the channel was on.
; Preserved: DE
GetLenClocks:
     push bc
     push hl

     ; HL = NRx4 of the channel, C = its status mask
     ld   h,a
     ld   a,$0F
     ld   c,$80
     inc  h
.findReg:
     add  5
     rlc  c
     dec  h
     jr   nz,.findReg
     ld   l,a
     ld   h,$FF

     ; Disable length
     ld   b,0
     bit  6,[hl]
     jr   z,.disabled
     ld   [hl],$00
.disabled:

     ; Done if the channel is off
     lda  rAUDENA
     and  c
     jr   z,.done
     cp   $04
     jp   z,.wave

     ; Time with the wave channel: length = 4
     wreg rAUD3ENA,$80
     wreg rAUD3LEN,-4
     wreg rAUD3HIGH,$C0
     wreg rAUD3LEN,-1
.waitWave:
     lda  rAUDENA
     and  $04
     jr   nz,.waitWave

     ; Clock length until the channel turns off
.count:
     ld   [hl],$40  ; enable length, causing an extra clock
     ld   [hl],$00
     inc  b
     lda  rAUDENA
     and  c
     jr   nz,.count
.finished:
     scf
.done:
     ld   a,b
     pop  hl
     pop  bc
     ret

     ; Time with square 2
.wave:
     wreg rAUD2ENV,$08
     wreg rAUD2LEN,-4
     wreg rAUD2HIGH,$C0
     wreg rAUD2LEN,-1
.waitSquare:
     lda  rAUDENA
     and  $02
     jr   nz,.waitSquare
     ld   c,$40
.waveCount:
     dec  c
     jr   z,.wave
     ld   [hl],$40
     ld   [hl],$00
     inc  b
     lda  rAUDENA
     and  $04
     jr   nz,.waveCount
     jr   .finished
