; The shell code that goes after the program. RGBDS lays code out in source
; order, so it is in this file, which every program includes at its end.

IF DEF(BUILD_MULTI)

; A test of the multi-test ROM prints nothing and returns to the driver
InitRuntime:
	ret

StdPrint:
	ret

PostExit:
	jp   MULTI_RETURN
Forever:
	jr   Forever

PlayByte:
	ret

ELSE

INCLUDE "console.s"

InitRuntime:
	call ConsoleInit
IF DEF(TEST_NAME)
	print_str "{TEST_NAME}",NEWLINE,NEWLINE
ENDC
	ret

StdPrint:
	push af
	sta  rSB
	wreg rSC,SC_START | SC_INTERNAL
	delay 2304
	pop  af
	jp   ConsolePrint

PostExit:
	call ConsoleShow
	call PlayByte
Forever:
	wreg rAUDENA,AUDENA_OFF    ; sound off
.loop:
	jr   .loop

PlayByte:
	ret

ENDC

; Closes the block of the program, which runs from WRAM. The multi-test driver
; runs from ROM, and a test that has data to put after the shell code (see
; instr_timing) defines KEEP_PROGRAM_OPEN and closes the block itself.
IF !DEF(MULTI_DRIVER) && !DEF(KEEP_PROGRAM_OPEN)
	ENDL
ENDC
