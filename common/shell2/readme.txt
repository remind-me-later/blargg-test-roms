Game Boy Tests Source Code
--------------------------

Building with RGBDS
-------------------
The tests are assembled with RGBDS (rgbasm, rgblink and rgbfix), tested
with version 1.0.4. To assemble a test ROM by hand, from the directory of
the suite:

	rgbasm -I ../common/shell2/ -I ../common/ -I ../hardware.inc/ \
	       -o test.o source_filename_here.s
	rgblink -o test.gb test.o
	rgbfix -f hg test.gb

build.sh, in the main directory of the repository, builds all the ROMs
that way and, with --check, compares them with the ones of the
gameboy-test-roms release (fetch-reference.sh downloads them). The hardware
definitions (rLCDC, rAUDENA...) come from hardware.inc, a submodule of the
repository.

The sources were written for WLA-DX and have been converted; the ROMs they
give are the same, byte for byte. The GBS and devcart builds that WLA-DX
had are not supported.

The multi-test ROM is built from multi.s, the driver, and one block per
test (built with BUILD_MULTI and MULTI_TEST defined). Its source was not
released: multi.s is a reconstruction, so build.sh does it.

Tests include "shell.inc" at the beginning and "shell_end.inc" at the end.
The code of the libraries that goes after the test is in shell_end.inc,
and the definitions and macros of the libraries are in the .inc files.
They are shared with the other suites, in common/shell2/ and common/
(see readme.txt there); suite.inc has the settings of this suite.

Framework
---------
Each test is in a single source file, and makes use of several library
source files from common/shell2/. This framework provides common services and
reduces code to only that which performs the actual test. Virtually all
tests include "shell.inc" at the beginning, which sets things up and
includes all the appropriate library files.

The reset handler does minimal GB hardware initialization, clears RAM,
sets up the text console, then runs main. Main can exit by returning or
jumping to "exit" with an error code in A. Exit reports the code then
goes into an infinite loop. If the code is 0, it doesn't do anything,
otherwise it reports the code. Code 1 is reported as "Failed", and the
rest as "Error <code>".

The default is to build a ROM. The other build types (GBS, devcart,
multi-test) aren't supported due to their complexity. I load
the code into RAM at $C000 since my devcart requires it, and I don't
want the normal ROM to differ in any way from what I've tested. This
also allows easy self-modifying code.

Several routines are available to print values and text to the console.
Most update a running CRC-32 checksum which can be checked with
check_crc, allowing ALL the output to be checked very easily. If the
checksum doesn't match, it is printed, so you can run the code on a GB
and paste the correct checksum into your code.


Macros
------
Some macros are used to make common operations more convenient. The left
is equivalent to the right:

	Macro               Equivalent
	-------------------------------------
	lda addr            ldh a,(addr-$FF00)
	
	sta addr            ldh (addr-$FF00),a
	
	wreg addr,data      ld  a,data
						ldh (addr-$FF00),a
	
	setb                ld  a,data
						ld  (addr),a
	
	setw                setb addr+0,<data
						setb addr+1,>data
	
	for_loop routine,begin,end,step
						calls routine with A set to successive values
	
	loop_n_times routine,count
						calls routine with A from 0 to count-1
	
	print_str "str"     prints string
	

-- 
Shay Green <gblargg@gmail.com>
