; Delays in cycles, milliseconds, etc.

; All routines are re-entrant (no global data). Routines never
; touch BC, DE, or HL registers. These ASSUME CPU is at normal
; speed. If running at double speed, msec/usec delays are half advertised.

; Delays n cycles, from 0 to 16777215
; Preserved: AF, BC, DE, HL
MACRO delay
     IF (\1) < 0
          FAIL "Delay must be >= 0"
     ENDC
     IF (\1) > 16777215
          FAIL "Delay must be < 16777216"
     ENDC
     delay_ (\1)&$FFFF, (\1)>>16
ENDM

; Delays n clocks, from 0 to 16777216*4. Must be multiple of 4.
; Preserved: AF, BC, DE, HL
MACRO delay_clocks
     IF (\1) % 4 != 0
          FAIL "Delay must be a multiple of 4"
     ENDC
     delay_ ((\1)/4)&$FFFF,((\1)/4)>>16
ENDM

; Delays n microseconds (1/1000000 second)
; n can range from 0 to 4000 usec.
; Preserved: AF, BC, DE, HL
MACRO delay_usec
     IF (\1) < 0
          FAIL "Delay must be >= 0"
     ENDC
     IF (\1) > 4000
          FAIL "Delay must be <= 4000 usec"
     ENDC
     delay_ (((\1) * 1048576 + 500000) / 1000000)&$FFFF,(((\1) * 1048576 + 500000) / 1000000)>>16
ENDM

; Delays n milliseconds (1/1000 second)
; n can range from 0 to 10000 msec.
; Preserved: AF, BC, DE, HL
MACRO delay_msec
     IF (\1) < 0
          FAIL "Delay must be >= 0"
     ENDC
     IF (\1) > 10000
          FAIL "Delay must be <= 10000 msec"
     ENDC
     delay_ (((\1) * 1048576 + 500) / 1000)&$FFFF, (((\1) * 1048576 + 500) / 1000)>>16
ENDM

     ; All the low/high quantities are to deal wla-dx's asinine
     ; restriction full expressions must evaluate to a 16-bit
     ; value. If the author ever rectifies this, all "high"
     ; arguments can be treated as zero and removed. Better yet,
     ; I'll just find an assembler that didn't crawl out of
     ; the sewer (this is one of too many bugs I've wasted
     ; hours working around).

     DEF max_short_delay = 28

     MACRO delay_long_
          ; 0+ to avoid assembler treating as memory read
          ld   a,0+((((\2)<<16)+(\1)) - 11) >> 16
          call delay_65536a_9_cycles_
          delay_nosave_ ((((\2)<<16)+(\1)) - 11)&$FFFF, 0
ENDM

     ; Doesn't save AF, allowing minimization of AF save/restore
     MACRO delay_nosave_
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

     MACRO delay_
          IF ((\2)*(max_short_delay+1))|(\1) > max_short_delay
               push af
               delay_nosave_ (((\2)<<16)+(\1) - 7)&$FFFF, (((\2)<<16)+(\1) - 7)>>16
               pop  af
          ELSE
               delay_short_ \1
          ENDC
ENDM

MACRO delay_short_
     IF (\1) < 0
          FAIL "assertion failed"
     ENDC
     IF (\1) > max_short_delay
          FAIL "assertion failed"
     ENDC

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
