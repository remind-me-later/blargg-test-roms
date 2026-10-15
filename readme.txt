Blargg's Gameboy hardware test ROMs. Originally hosted at http://blargg.parodius.com/gb-tests/
before parodious.com went down.
New official location: http://blargg.8bitalley.com/parodius/gb-tests/



Building the ROMs
-----------------
The sources of the tests, in the source/ directories, were written for the
WLA-DX assembler. They have been converted to RGBDS (rgbasm, rgblink and
rgbfix; tested with version 1.0.4), and give the same ROMs as the released
ones, byte for byte.

	./build.sh                  builds all the ROMs into build/
	./build.sh --check          also compares them with the released ones
	./build.sh --check DIR      compares them with the ROMs of another copy
	                            of the release, found at the same paths in DIR
	./build.sh --only PREFIX    only the ROMs whose path starts with PREFIX

roms.tsv lists the ROMs and their sources. CI (.github/workflows) builds
them all and compares them with the ones of the gameboy-test-roms release.

The GBS and devcart builds that WLA-DX had are not supported.


What was not released
---------------------
Some of the sources were never released, and some were out of date. The
files below were written for this repository from the code of the released
ROMs, to assemble to the same bytes; their names and comments are guesses.
Each says so at its beginning.

	oam_bug/source/oam_bug.inc        included by the oam_bug tests
	dmg_sound/source/apu.s            included by the sound tests (also in
	cgb_sound/source/apu.s            the sources of interrupt_time, halt_bug
	                                  and the multi-test ROMs)
	dmg_sound/source/test_chan.s      included by the length counter and
	cgb_sound/source/test_chan.s      trigger tests
	halt_bug/source/halt_bug.s        halt_bug.gb had no source
	*/source/multi.s                  the drivers of the multi-test ROMs
	                                  (cpu_instrs, mem_timing, mem_timing-2,
	                                  oam_bug, dmg_sound, cgb_sound)

interrupt_time/source/interrupt_time.s needed the libraries of the other
suites and was built with the second version of the shell: it has copies of
them in its common/. Its source expected another checksum than the ROM did;
it has the ROM's. The released build commands also defined the name of
the test (TEST_NAME), the name in the header (ROM_NAME) and, for the sound
suites, the kind of hardware (REQUIRE_DMG, REQUIRE_CGB): the sources define
them now.

WLA-DX assembled two things differently from what the sources say, and the
ROMs have what it assembled: `stop` was one byte (the sources follow it with
a nop, and now have the two-byte RGBDS stop), and the unary ~ of
`and ~$04` in instr_timing and interrupt_time did nothing.
