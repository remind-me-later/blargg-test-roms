; Included at beginning of all programs that use the standard shell. The
; program ends with INCLUDE "shell_end.inc", which adds the shell code that
; has to follow it in the ROM.
;
; Assemble with the common/ directory on the include path:
;   rgbasm -I common/ -o test.o test.s

INCLUDE "build_rom.s"
