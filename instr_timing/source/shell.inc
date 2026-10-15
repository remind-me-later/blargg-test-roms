; Included at beginning of all programs that use the standard shell. The
; program ends with INCLUDE "shell_end.inc", which adds the shell code that
; has to follow it in the ROM.
;
; Assemble with the common/ directory on the include path:
;   rgbasm -I common/ -o test.o test.s
;
; With BUILD_MULTI (and MULTI_TEST, the number of the test) defined, the test
; is built as a block of the multi-test ROM instead of as a ROM of its own.

IF DEF(BUILD_MULTI)
INCLUDE "build_multi.s"
ELSE
INCLUDE "build_rom.s"
ENDC
