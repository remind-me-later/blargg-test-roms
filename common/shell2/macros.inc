; General macros

; Reads A from addr, from $FF00 to $FFFF
; Preserved: F, BC, DE, HL
; Time: 3 cycles
MACRO lda ; addr
     ldh  a,[\1]
ENDM

; Writes A to addr, from $FF00 to $FFFF
; Preserved: AF, BC, DE, HL
; Time: 3 cycles
MACRO sta ; addr
     ldh  [\1],a
ENDM

; Writes immediate data to addr, from $FF00 to $FFFF
; Preserved: F, BC, DE, HL
; Time: 5 cycles
MACRO wreg
     ld   a,\2
     sta  \1
ENDM

; Writes byte to addr
; Preserved: F, BC, DE, HL
; Time: 6 cycles
MACRO setb ; addr, data
     ld   a,\2
     ld   [\1],a
ENDM

; Writes word to addr
; Preserved: F, BC, DE, HL
; Time: 12 cycles
MACRO setw ; addr, data
     ld   a,LOW(\2)
     ld   [\1],a
     ld   a,HIGH(\2)
     ld   [\1+1],a
ENDM

; Calls routine multiple times, with A having the
; value 'start' the first time, 'start+step' the
; second time, up to 'end' for the last time.
; Preserved: BC, DE, HL
MACRO for_loop ; routine,start,end,step
     ld   a,\2

for_loop\@:
     push af
     call \1
     pop  af

     add  \4
     cp   LOW((\3 + \4))
     jr   nz,for_loop\@
ENDM

; Calls routine n times. The value of A in the routine
; counts from 0 to n-1.
; Preserved: BC, DE, HL
MACRO loop_n_times ; routine,n
     for_loop \1,0,\2 - 1,+1
ENDM

; Same as for_loop, but counts with 16-bit value in BC.
; Preserved: DE, HL
MACRO for_loop16 ; routine,start,end,step
     ld   bc,\2

for_loop16\@:
     push bc
     call \1
     pop  bc

     ld   a,c
     add  LOW(\4)
     ld   c,a

     ld   a,b
     adc  HIGH(\4)
     ld   b,a

     cp   HIGH((\3+\4))
     jr   nz,for_loop16\@

     ld   a,c
     cp   LOW((\3+\4))
     jr   nz,for_loop16\@
ENDM
