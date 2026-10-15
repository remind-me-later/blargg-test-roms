; Included at beginning of all programs that use standard shell. The program
; ends with INCLUDE "shell_end.inc", which adds the shell code that has to
; follow it in the ROM.
;
; Assemble with the common/ directory on the include path:
;   rgbasm -I common/ -o test.o test.s

; The released ROMs were built for one kind of hardware.
DEF REQUIRE_DMG = 1

INCLUDE "build_rom.s"
