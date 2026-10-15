; CPU speed manipulation.

; Switches to normal speed. No effect on DMG.
; Preserved: BC, DE, HL
cpu_norm:
     ; Do nothing if not CGB
     ld   a,[gb_id]
     and  gb_id_cgb
     ret  z
     
     lda  rSPD
     rlca
     ret  nc
     jr   cpu_speed_toggle


; Switches to double speed. No effect on DMG.
; Preserved: BC, DE, HL
cpu_fast:
     ; Do nothing if not CGB
     ld   a,[gb_id]
     and  gb_id_cgb
     ret  z
     
     lda  rSPD
     rlca
     ret  c
cpu_speed_toggle:
     di
     lda  rIE
     push af
     xor  a
     sta  rIE
     sta  rIF
     wreg rJOYP,$30
     wreg rSPD,1
     stop    ; RGBDS assembles this as $10 $00, the old stop + nop
     pop  af
     sta  rIE
     ret


; Determines current CPU speed without using KEY1.
; A=1 if fast, 0 if normal. Always 0 on DMG.
; Preserved: BC, DE,HL
get_cpu_speed:
     push bc
     call sync_apu
     wreg rAUD1HIGH,$C0
     wreg rAUD1LEN,-1
     wreg rAUD1ENV,8
     wreg rAUD1HIGH,$C0
     ld   bc,-$262
:    inc  bc
     lda  rAUDENA
     and  1
     jr   nz,:-
     ld   a,0
     bit  7,b
     jr   nz,:+
     inc  a
:    pop  bc
     ret
