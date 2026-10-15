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

DEF MAX_SHORT_DELAY EQU 28

MACRO? delay_long_
	; 0+ to avoid assembler treating as memory read
	ld   a,0+((((\2)<<16)+(\1)) - 11) >> 16
	call Delay65536A9Cycles_
	delay_nosave_ ((((\2)<<16)+(\1)) - 11)&$FFFF, 0
ENDM

; Doesn't save AF, allowing minimization of AF save/restore
MACRO? delay_nosave_
	; 65536+11     = maximum delay using Delay256A9Cycles_
	; 255+22  = maximum delay using DelayA20Cycles
	; 22      = minimum delay using DelayA20Cycles
	IF (\2) > 1
		delay_long_ \1, \2
	ELSE
		IF (\2)*(\1) > 11
			delay_long_ \1, \2
		ELSE
			IF ((\2)*(255+22+1))|(\1) > 255+22
				ld   a,HIGH(((((\2)<<16)+(\1)) - 11))
				call Delay256A9Cycles_
				delay_nosave_ LOW(((((\2)<<16)+(\1)) - 11)), 0
			ELSE
				IF (\1) >= 22
					ld   a,(\1) - 22
					call DelayA20Cycles
				ELSE
					delay_short_ \1
				ENDC
			ENDC
		ENDC
	ENDC
ENDM

MACRO? delay_
	IF ((\2)*(MAX_SHORT_DELAY+1))|(\1) > MAX_SHORT_DELAY
		push af
		delay_nosave_ (((\2)<<16)+(\1) - 7)&$FFFF, (((\2)<<16)+(\1) - 7)>>16
		pop  af
	ELSE
		delay_short_ \1
	ENDC
ENDM

MACRO? delay_short_
	ASSERT (\1) >= 0, "Short delay must be >= 0"
	ASSERT (\1) <= MAX_SHORT_DELAY, "Short delay must be <= {d:MAX_SHORT_DELAY}"

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
		call DelayUnrolled_ + 10 - (\1)
	ENDC
ENDM
