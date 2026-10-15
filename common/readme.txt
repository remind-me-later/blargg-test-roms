Shared sources
--------------
The tests of all the suites are built on the same shell, and these are its
sources. There are two versions of it, because Blargg changed it between
the first suites and the later ones:

shell1/   cpu_instrs, mem_timing, instr_timing
shell2/   cgb_sound, dmg_sound, oam_bug, mem_timing-2, halt_bug,
          interrupt_time
.         used by both: cpu_speed.s, timer.s, ppu.s, console_font.inc
          (the font of the console) and rgbdscheck.inc

A test starts with INCLUDE "shell.inc" and ends with INCLUDE "shell_end.inc".
shell.inc pulls in the header of the ROM and the definitions of the
libraries; shell_end.inc has the code of the libraries, which has to be after
the test in the ROM. In shell2, definitions are in X.inc and code in X.s.

The tests are assembled from the directory of their suite, which has the
files only that suite has (and, for shell2, suite.inc, with the cartridge
type, RAM size and so on). Include paths, in this order:

	-I ../common/shellN/ -I ../common/ -I ../hardware.inc/

Layout of the code. Labels are at the beginning of the line and everything
else is indented with tabs, one for each level (the body of a macro, of an
IF); spaces are only for alignment. An instruction is written `ld a, [hl]`,
with one space after the mnemonic and after each comma, as in pokecrystal.
The comments that follow the code of several lines in a row are aligned with
spaces, one space after the longest line, and start with "; ". .editorconfig
has the settings.

Names. They follow the style guide of gbdev.io: labels are PascalCase
(StdReset, PrintCRC), local labels camelCase (.nextInstr), RAM labels have a
prefix for the kind of RAM (wTestCode, hChecksum, sFinalResult), constants are
CAPS_SNAKE (CONSOLE_WIDTH) and macros snake_case (set_test, delay_msec). The
names are Blargg's, written that way. A trailing underscore (SetTest_,
PrintStr_) is a helper of the routine or macro that has the name without it.

RAM. The variables of the shell are listed in variables.inc of each shell,
as labels in sections with fixed addresses (the ROMs have to be the released
ones), named as the style guide of gbdev.io says: w for WRAM, h for HRAM, s
for cartridge RAM (wTestCode, hChecksum, sFinalResult). A test that has
variables of its own declares a section that starts at wShellVariablesEnd or
hShellVariablesEnd. The sections are unionized, so that the tests of a
multi-test ROM, each assembled on its own, use the same RAM.

multi_driver.s is the driver of the multi-test ROMs. It was reconstructed
from the released ROMs, like apu.s and test_chan.s of shell2 (see readme.txt
in the main directory).
