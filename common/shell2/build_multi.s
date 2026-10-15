; Build as one of the tests of the multi-test ROM
;
; The test is stored in a block of the ROM, at
; $4000 + (MULTI_TEST & 3) * $1000 in bank 1 + MULTI_TEST / 4, which the
; driver (multi.s, in bank 0) copies to $C000 before running it. The test
; ends by jumping back to the driver at MULTI_RETURN.

DEF CUSTOM_PRINT EQU 1
DEF CUSTOM_EXIT EQU 1
DEF MULTI_RETURN EQU $3F00

INCLUDE "shell.s"
