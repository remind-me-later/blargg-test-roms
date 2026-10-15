; Sound chip utilities

; Turns APU off
; Preserved: BC, DE, HL
sound_off:
     wreg rAUDENA,AUDENA_OFF
     ret


; Turns APU on
; Preserved: BC, DE, HL
sound_on:
     wreg rAUDENA,AUDENA_ON  ; power
     wreg rAUDTERM,$FF  ; mono
     wreg rAUDVOL,$77  ; volume
     ret


; Synchronizes to APU length counter within
; tens of clocks. Uses square 2 channel.
; Preserved: BC, DE, HL
sync_apu:
     wreg rAUD2HIGH,$00  ; disable length
     wreg rAUD2LEN,$3E  ; length = 2 (in case of extra len clk)
     wreg rAUD2ENV,$08  ; silent without disabling channel
     wreg rAUD2HIGH,$C0  ; start length
:    lda  rAUDENA      ; wait for length to reach zero
     and  $02
     jr   nz,:-
     ret


; Synchronizes to first square sweep within
; tens of clocks. Uses square 1 channel.
; Preserved: BC, DE, HL
sync_sweep:
     wreg rAUD1SWEEP,$11  ; sweep period = 1, shift = 1
     wreg rAUD1ENV,$08  ; silent without disabling channel
     wreg rAUD1LOW,$FF  ; freq = $3FF
     wreg rAUD1HIGH,$83  ; start
:    lda  rAUDENA
     and  $01
     jr   nz,:-
     ret


; Copies 16-byte wave from (HL) to wave RAM
; Preserved: BC, DE
load_wave:
     push bc
     wreg rAUD3ENA,$00  ; disable while writing
     ld   c,$30
:    ld   a,[hli]
     ld   [$FF00+c],a
     inc  c
     bit  6,c
     jr   z,:-
     pop  bc
     ret


; Makes short beep
; Preserved: BC, DE, HL
beep:
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
mark_sound:
     push bc
     ld   c,a
     ld   b,8
     wreg rAUD1SWEEP,0
     wreg rAUD1LEN,$80
     wreg rAUD1LOW,$F8
:    ld   a,$60
     rl   c
     jr   nc,:+
     ld   a,$A0
:    sta  rAUD1ENV
     wreg rAUD1HIGH,$87
     delay_usec 300
     wreg rAUD1ENV,0
     delay_usec 100
     dec  b
     jr   nz,:--
     pop  bc
     ret


; Fills wave RAM with A
; Preserved: BC, DE, HL
fill_wave:
     push bc
     ld   c,$30
:    ld   [$FF00+c],a
     inc  c
     bit  6,c
     jr   z,:-
     pop  bc
     ret


; Gets current length counter value for
; channel with mask A into A. Length counter
; must be enabled for that channel.
; Preserved: BC, DE, HL
get_len_a:
     push bc
     ld   c,a
     ld   b,0
:    lda  rAUDENA      ; 3
     and  c         ; 1
     jr   z,:+       ; 2
     delay 4096-10
     inc  b         ; 1
     jr   nz,:-      ; 3
:    ld   a,b
     pop  bc
     ret


; Synchronizes exactly to length clock. Next length clock
; occurs by 4079 clocks after this returns. Uses NR2x.
; Preserved: AF, BC, DE, HL
sync_length:
     push af
     push hl
     
     ld   hl,rAUDENA
     wreg rAUD2ENV,$08  ; silent without disabling channel
     wreg rAUD2HIGH,$40  ; avoids extra length clock on trigger
     wreg rAUD2LEN,-2   ; length = 2, in case clock occurs immediately
     wreg rAUD2HIGH,$C0  ; start length
     
     ; Coarse sync
     ld   a,$02
:    and  [hl]
     jr   nz,:-
     
     ; Fine sync. Slowly moves "forward" until
     ; length clock occurs just before reading NR52.
:    delay 4097-20
     wreg rAUD2LEN,-1   ; 5
     wreg rAUD2HIGH,$C0  ; 5
     lda  rAUDENA      ; 3
     delay 2        ; 2
     and  $02       ; 2
     jr   nz,:-      ; 3
     
     pop  hl
     pop  af
     ret


; Delays n*4096 cycles
; Preserved: BC, DE, HL
MACRO delay_frames ; n
     ld   a,\1
     call delay_frames_
ENDM


; Delays A*4096+13 cycles (including CALL)
; Preserved: BC, DE, HL
delay_a_frames:
     or   a              ; 1
     jr   nz,:+           ; 3
                         ; -1
     ret
delay_frames_:           ; delays 4096*A-2 cycles (including CALL)
     push af             ; 4
     ld   a,256-13-20-12 ; 2
     jr   :+++             ; 3
:
:    push af             ; 4
     ld   a,256-13-20    ; 2
:    call delay_a_20_cycles
     delay 4096-256
     pop  af             ; 3
     dec  a              ; 1
     jr   nz,:--           ; 3
                         ; -1
     ret


MACRO test_chan_timing ; chan, iter
     ld   a,\1
     call print_dec
     call print_space
     ld   a,\2
:    push af
     test_chan 1<<\1, \1*5+rAUD1SWEEP
     pop  af
     dec  a
     jr   nz,:-
     call print_newline
ENDM

MACRO test_chans
     test_chan_timing 0,\1
     test_chan_timing 1,\1
     test_chan_timing 2,\1
     test_chan_timing 3,\1
ENDM
