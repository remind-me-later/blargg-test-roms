# Blargg's Game Boy hardware test ROMs

Blargg's Gameboy hardware test ROMs. Originally hosted at
<http://blargg.parodius.com/gb-tests/> before parodius.com went down.
New official location: <http://blargg.8bitalley.com/parodius/gb-tests/>

## Credits

The tests, their sources and the text of the readmes of the suites are by
Shay Green <gblargg@gmail.com> ("Blargg"). The readme of each suite says
what was changed in it here. The files that were not released, and were
written for this repository, are listed in
[What was not released](#what-was-not-released).

## Building the ROMs

The sources of the tests were written for the WLA-DX assembler. They have
been converted to RGBDS (`rgbasm`, `rgblink` and `rgbfix`; tested with version
1.0.4), and give the same ROMs as the released ones, byte for byte. The
ROMs are not kept in the repository: they are built, and compared with the
ones of the gameboy-test-roms release. It needs GNU make.

| Command | What it does |
| --- | --- |
| `make` | builds all the ROMs into `build/` |
| `./fetch-reference.sh` | downloads the ROMs of the release into `reference/` (the check needs them) |
| `make check` | also compares the ROMs with those |
| `make check REFERENCE=DIR` | compares them with the ROMs of another copy of the release, found at the same paths in `DIR` |
| `make cpu_instrs` | only the ROMs of a suite |
| `make -j` | builds in parallel; only what changed is built again |
| `make clean` | removes `build/` |

The names of the hardware registers and memory areas (`rLCDC`, `rAUDENA`,
`TILEMAP0`...) are the ones of hardware.inc, which is a submodule: after
cloning, run

```sh
git submodule update --init
```

The Makefile has the list of the suites. CI (`.github/workflows`) builds the
ROMs and compares them with the ones of the gameboy-test-roms release.

The tools run with `-Weverything`, and the sources give no warnings. To add
options, set `RGBASMFLAGS`, `RGBLINKFLAGS` or `RGBFIXFLAGS` (CI sets
`-Werror`).

The GBS and devcart builds that WLA-DX had are not supported.

## Layout

Each suite has a directory with the sources of its tests, its readme and
the files that only that suite has. The shell (the code that sets up the
hardware, the console and the exit) and the libraries are shared, in
`common/`:

| Directory | What it has |
| --- | --- |
| `common/shell1/` | the first version of the shell, used by cpu_instrs, mem_timing and instr_timing |
| `common/shell2/` | the second version, used by the other suites; each of them has a `suite.inc` with its settings |
| `common/` | what both use: `cpu_speed.s`, `timer.s`, `ppu.s`, the font of the console and the check of the RGBDS version |

A test is assembled from the directory of its suite, with the directories
of its shell and of `common/` on the include path (the Makefile does it, and
says which shell each suite uses). [common/shell2/README.md](common/shell2/README.md)
and the readme of each suite say how to do it by hand.

## What was not released

Some of the sources were never released, and some were out of date.

`oam_bug/oam_bug.inc` was not in the zip of the oam_bug ROMs, but Blargg's own
is in `oam_bug-2.zip`, a later revision of that suite (its ROMs are not the
ones of the release). The Wayback Machine archived the zip in 2016:

<https://web.archive.org/web/20160731144356/http://blargg.8bitalley.com/parodius/gb-tests/oam_bug-2.zip>

The file is `source/common/oam_bug.inc` there. Here it is ported to RGBDS, with
its names changed to the ones of this repository, and assembles to the code
of the released ROMs. The Wayback Machine also has the other zips of
`gb-tests/` (from either address above); the sources in them are the ones this
repository started from, and none has the files below.

The files below were written for this repository from the code of the
released ROMs, to assemble to the same bytes; their names and comments are
guesses. Each says so at its beginning.

| File | Why |
| --- | --- |
| `common/shell2/apu.s` | included by the sound tests and by the multi-test ROMs |
| `common/shell2/test_chan.s` | included by the length counter and trigger tests of the sound suites |
| `halt_bug/halt_bug.s` | `halt_bug.gb` had no source |
| `common/shell1/multi_driver.s` | the drivers of the multi-test ROMs (one for the cpu_instrs and mem_timing ROMs, one for the others; `*/multi.s` gives the names) |
| `common/shell2/multi_driver.s` | (as above) |

`interrupt_time/interrupt_time.s` needed the libraries of the other suites
and was built with the second version of the shell (`common/shell2/`). Its
source expected another checksum than the ROM did; it has the ROM's. The
released build commands also defined the name of the test (`TEST_NAME`), the
name in the header (`ROM_NAME`) and, for the sound suites, the kind of
hardware (`REQUIRE_DMG`, `REQUIRE_CGB`): the sources define them now.

WLA-DX assembled two things differently from what the sources say, and the
ROMs have what it assembled: `stop` was one byte (the sources follow it with
a `nop`, and now have the two-byte RGBDS `stop`), and the unary `~` of
`and ~$04` in instr_timing and interrupt_time did nothing.

## Names of the files

The sources have no spaces, commas or parentheses in their names, which make
cannot take: the test that the release has as `03-op sp,hl.gb` is
`cpu_instrs/03-op_sp_hl.s` here, and builds
`build/cpu_instrs/individual/03-op_sp_hl.gb`. `make check` finds the ROM of
the release for each of them.
