; Included at the beginning of every program that uses the shell. The program
; ends with INCLUDE "shell_end.inc", which adds the shell code that has to
; follow it in the ROM.
;
; Assemble from the directory of the suite, with the shared
; directories on the include path:
;   rgbasm -I ../common/shell2/ -I ../common/ -I ../hardware.inc/ -o test.o test.s
;
; The suite has a suite.inc, which defines
;   CART_TYPE, RAM_SIZE   bytes of the cartridge header
;   ROM_FILL              the byte that fills the unused space of bank 0
; and may define
;   REQUIRE_DMG or REQUIRE_CGB   the ROMs run on one kind of hardware
;   CHECK_GB_ID                  sanitize the value that the boot ROM leaves in A
;
; With BUILD_MULTI (and MULTI_TEST, the number of the test) defined, the test
; is built as a block of the multi-test ROM instead of as a ROM of its own.

INCLUDE "rgbdscheck.inc"
INCLUDE "suite.inc"

IF DEF(BUILD_MULTI)
INCLUDE "build_multi.s"
ELSE
INCLUDE "build_rom.s"
ENDC
