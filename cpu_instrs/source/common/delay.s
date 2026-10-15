; Delays in cycles, milliseconds, etc.

; All routines are re-entrant (no global data). Routines never
; touch BC, DE, or HL registers. These ASSUME CPU is at normal
; speed. If running at double speed, msec/usec delays are half advertised.

; Delays n cycles, from 0 to 16777215
; Preserved: AF, BC, DE, HL
MACRO? delay
     ASSERT (\1) >= 0, "Delay must be >= 0"
     ASSERT (\1) <= 16777215, "Delay must be < 16777216"
     delay_ (\1)&$FFFF, (\1)>>16
ENDM

; Delays n clocks, from 0 to 16777216*4. Must be multiple of 4.
; Preserved: AF, BC, DE, HL
MACRO? delay_clocks
     ASSERT (\1) % 4 == 0, "Delay must be a multiple of 4"
     delay_ ((\1)/4)&$FFFF,((\1)/4)>>16
ENDM

; Delays n microseconds (1/1000000 second)
; n can range from 0 to 4000 usec.
; Preserved: AF, BC, DE, HL
MACRO? delay_usec
     ASSERT (\1) >= 0, "Delay must be >= 0"
     ASSERT (\1) <= 4000, "Delay must be <= 4000 usec"
     delay_ (((\1) * 1048576 + 500000) / 1000000)&$FFFF,(((\1) * 1048576 + 500000) / 1000000)>>16
ENDM

; Delays n milliseconds (1/1000 second)
; n can range from 0 to 10000 msec.
; Preserved: AF, BC, DE, HL
MACRO? delay_msec
     ASSERT (\1) >= 0, "Delay must be >= 0"
     ASSERT (\1) <= 10000, "Delay must be <= 10000 msec"
     delay_ (((\1) * 1048576 + 500) / 1000)&$FFFF, (((\1) * 1048576 + 500) / 1000)>>16
ENDM

; The delay is passed to the helper macros below as two arguments, its low
; 16 bits and the rest. The original assembler could only evaluate 16-bit
; expressions, hence the split, which is kept so that the macros stay as
; they were.

DEF max_short_delay = 28

MACRO? delay_long_
     ; 0+ to avoid assembler treating as memory read
     ld   a,0+((((\2)<<16)+(\1)) - 11) >> 16
     call delay_65536a_9_cycles_
     delay_nosave_ ((((\2)<<16)+(\1)) - 11)&$FFFF, 0
ENDM

; Doesn't save AF, allowing minimization of AF save/restore
MACRO? delay_nosave_
     ; 65536+11     = maximum delay using delay_256a_9_cycles_
     ; 255+22  = maximum delay using delay_a_20_cycles
     ; 22      = minimum delay using delay_a_20_cycles
     IF (\2) > 1
          delay_long_ \1, \2
     ELSE
          IF (\2)*(\1) > 11
               delay_long_ \1, \2
          ELSE
               IF ((\2)*(255+22+1))|(\1) > 255+22
                    ld   a,HIGH(((((\2)<<16)+(\1)) - 11))
                    call delay_256a_9_cycles_
                    delay_nosave_ LOW(((((\2)<<16)+(\1)) - 11)), 0
               ELSE
                    IF (\1) >= 22
                         ld   a,(\1) - 22
                         call delay_a_20_cycles
                    ELSE
                         delay_short_ \1
                    ENDC
               ENDC
          ENDC
     ENDC
ENDM

MACRO? delay_
     IF ((\2)*(max_short_delay+1))|(\1) > max_short_delay
          push af
          delay_nosave_ (((\2)<<16)+(\1) - 7)&$FFFF, (((\2)<<16)+(\1) - 7)>>16
          pop  af
     ELSE
          delay_short_ \1
     ENDC
ENDM


; Delays A cycles + overhead
; Preserved: BC, DE, HL
; Time: A+20 cycles (including CALL)
delay_a_20_cycles:
:    sub  5    ; 2
jr   nc,:- ;3/2 do multiples of 5
rra       ; 1
jr   nc,:+ ;3/2 bit 0
:    adc  1    ; 2
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
:    delay 256-4
dec  a              ; 1
jr   nz,:-           ;3/2
ret                 ; 4

; Delays A*65536 cycles + overhead
; Preserved: BC, DE, HL
; Time: A*65536+12 cycles (including CALL)
delay_65536a_12_cycles:
or   a              ; 1
ret  z              ;5/2
delay_65536a_9_cycles_:
:    delay 65536-4
dec  a              ; 1
jr   nz,:-           ;3/2
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
ds max_short_delay-10, $00 ; NOP repeated several times
delay_unrolled_:
ret

MACRO? delay_short_
     ASSERT (\1) >= 0, "Short delay must be >= 0"
     ASSERT (\1) <= max_short_delay, "Short delay must be <= {d:max_short_delay}"

     IF (\1) == 1
          nop
     ENDC
     IF (\1) == 2
          nop
          nop
     ENDC
     IF (\1) == 3
          db $18, $00 ; JR +0
     ENDC
     IF (\1) == 4
          db $18, $00 ; JR +0
          nop
     ENDC
     IF (\1) == 5
          db $18, $00 ; JR +0
          nop
          nop
     ENDC
     IF (\1) == 6
          db $18, $00 ; JR +0
          db $18, $00 ; JR +0
     ENDC
     IF (\1) == 7
          push af
          pop  af
     ENDC
     IF (\1) == 8
          push af
          pop  af
          nop
     ENDC
     IF (\1) == 9
          push af
          pop  af
          nop
          nop
     ENDC
     IF (\1) >= 10
          call delay_unrolled_ + 10 - (\1)
     ENDC
ENDM
