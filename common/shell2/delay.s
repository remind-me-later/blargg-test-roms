; Delays A cycles + overhead
; Preserved: BC, DE, HL
; Time: A+20 cycles (including CALL)
delay_a_20_cycles:
.loop:
     sub  5    ; 2
     jr   nc,.loop ;3/2 do multiples of 5
     rra       ; 1
     jr   nc,.next ;3/2 bit 0
.next:
     adc  1    ; 2
     ret  nc   ;5/2 -1: 0 cycles
     ret  z    ;5/2  0: 2 cycles
     nop       ; 1   1: 4 cycles
     ret       ; 4 (thanks to dclxvi for original algorithm)

; Delays A*256 cycles + overhead
; Preserved: BC, DE, HL
; Time: A*256+12 cycles (including CALL)
delay_256a_12_cycles:
     or   a              ; 1
     ret  z              ; 5/2
delay_256a_9_cycles_:
.loop:
     delay 256-4
     dec  a              ; 1
     jr   nz,.loop        ;3/2
     ret                 ; 4

; Delays A*65536 cycles + overhead
; Preserved: BC, DE, HL
; Time: A*65536+12 cycles (including CALL)
delay_65536a_12_cycles:
     or   a              ; 1
     ret  z              ;5/2
delay_65536a_9_cycles_:
.loop:
     delay 65536-4
     dec  a              ; 1
     jr   nz,.loop        ;3/2
     ret                 ; 4

; Delays H*256+L cycles + overhead
; Preserved: AF, BC, DE, HL
; Time: H*256+L+51 cycles
delay_hl_51_cycles:
     push af
     ld   a,h
     call delay_256a_12_cycles
     ld   a,l
     call delay_a_20_cycles
     pop  af
     ret

     ; delay_short_ macro calls into these
     ds MAX_SHORT_DELAY-10, $00 ; NOP repeated several times
delay_unrolled_:
     ret
