Shared sources
--------------
The tests of all the suites are built on the same shell, and these are its
sources. There are two versions of it, because Blargg changed it between
the first suites and the later ones:

shell1/   cpu_instrs, mem_timing, instr_timing
shell2/   cgb_sound, dmg_sound, oam_bug, mem_timing-2, halt_bug,
          interrupt_time
.         used by both: cpu_speed.s, timer.s, ppu.s, console.bin (the
          font of the console) and rgbdscheck.inc

A test starts with INCLUDE "shell.inc" and ends with INCLUDE "shell_end.inc".
shell.inc pulls in the header of the ROM and the definitions of the
libraries; shell_end.inc has the code of the libraries, which has to be after
the test in the ROM. In shell2, definitions are in X.inc and code in X.s.

The tests are assembled from the source/ directory of their suite, which has
the files only that suite has (and, for shell2, suite.inc, with the
cartridge type, RAM size and so on). Include paths, in this order:

	-I ../../common/shellN/ -I ../../common/ -I ../../hardware.inc/

multi_driver.s is the driver of the multi-test ROMs. It was reconstructed
from the released ROMs, like apu.s and test_chan.s of shell2 (see readme.txt
in the main directory).
