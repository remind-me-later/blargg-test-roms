# Builds Blargg's Game Boy test ROMs with RGBDS (rgbasm, rgblink, rgbfix).
# Tested with RGBDS 1.0.4 and GNU make 4.x. The hardware definitions come from
# the hardware.inc submodule (git submodule update --init).
#
#   make                  build every ROM into build/
#   make check            also compare each ROM, byte for byte, with the one of
#                         the gameboy-test-roms release in reference/, which
#                         ./fetch-reference.sh downloads (REFERENCE=DIR for
#                         another copy of the release)
#   make SUITE            only the ROMs of a suite: cpu_instrs, mem_timing,
#                         instr_timing, mem_timing-2, oam_bug, dmg_sound,
#                         cgb_sound, interrupt_time or halt_bug
#   make build/cpu_instrs/individual/01-special.gb
#                         one ROM
#   make clean
#
# The tools run with -Weverything. RGBASMFLAGS, RGBLINKFLAGS and RGBFIXFLAGS
# add options to them: RGBASMFLAGS=-Werror makes a warning fatal.
#
# A test is assembled from the directory of its suite, which has the files of
# the suite, with the shell of the suite and common/ on the include path. The
# digits at the beginning of the name of a source mark it as a test; the order
# of the names is the order of the tests in the multi-test ROM.

MAKEFLAGS += --no-builtin-rules --no-builtin-variables
.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

RGBASM    ?= rgbasm
RGBLINK   ?= rgblink
RGBFIX    ?= rgbfix
BUILD     ?= build
REFERENCE ?= reference

asmflags  = -Weverything $(RGBASMFLAGS)
linkflags = -Weverything $(RGBLINKFLAGS)
fixflags  = -Weverything $(RGBFIXFLAGS)

ROMS :=

# Recipes ----------------------------------------------------------------------

# $(call assemble,SUITE,SHELL,DEFINES): $< into $@, with the dependencies in $(@:.o=.d)
define assemble
@mkdir -p $(@D)
$(RGBASM) $(asmflags) $(3) -I $(1)/ -I common/$(2)/ -I common/ -I hardware.inc/ \
	-M $(@:.o=.d) -MP -MQ $@ -o $@ $<
endef

# $(call link,PAD): the objects of the prerequisites into $@
define link
@mkdir -p $(@D)
$(RGBLINK) $(linkflags) -p $(1) -o $@ $^
endef

# $(call pad_to,SIZE,PAD): $@ filled with the pad byte up to SIZE bytes
define pad_to
size=$$(wc -c < $@); \
if [ $$size -lt $(1) ]; then \
	head -c $$(($(1) - size)) /dev/zero | tr '\0' "$$(printf '\\%03o' $$(($(2))))" >> $@; \
fi
endef

# The checksums of the header and of the ROM
define fix
$(RGBFIX) $(fixflags) -f hg $@
endef

# The same, but the global checksum of the released ROMs of cpu_instrs and
# mem_timing covers bank 0 only: it was computed before the tests were added.
define fix_bank0
$(RGBFIX) $(fixflags) -f h $@
head -c 16384 $@ > $@.bank0
$(RGBFIX) -f g $@.bank0
dd if=$@.bank0 of=$@ bs=1 skip=334 seek=334 count=2 conv=notrunc 2> /dev/null
rm -f $@.bank0
endef

# Rules of a suite ---------------------------------------------------------------

# The object of a test, which is assembled as a ROM of its own
# $(call object,SUITE,SHELL,TEST)
define object
$(BUILD)/obj/$(1)/$(3).o: $(1)/$(3).s | hardware.inc/hardware.inc
	$$(call assemble,$(1),$(2),)
endef

# The ROM of a test
# $(call rom,SUITE,ROMDIR,TEST,PAD)
define rom
$(2)$(3).gb: $(BUILD)/obj/$(1)/$(3).o
	$$(call link,$(4))
	$$(fix)
endef

# The object of a test as a block of the multi-test ROM, MULTI_TEST being its number
# $(call multi_object,SUITE,SHELL,TEST,NUMBER)
define multi_object
$(BUILD)/obj/$(1)/$(3).multi.o: $(1)/$(3).s | hardware.inc/hardware.inc
	$$(call assemble,$(1),$(2),-D BUILD_MULTI=1 -D MULTI_TEST=$(4))
endef

# $(call suite,NAME,SHELL,ROMDIR,PAD,TESTS,MULTI,SIZE,BANK0)
#   NAME    directory of the suite, and the target that builds its ROMs
#   SHELL   shell1 or shell2, in common/
#   ROMDIR  where the ROMs of its tests go in build/ (empty: build/)
#   PAD     the byte that fills the gaps of the ROMs
#   TESTS   the sources that are tests, without .s
#   MULTI   the multi-test ROM, without .gb, or empty if the suite has none
#   SIZE    the size of the multi-test ROM
#   BANK0   if not empty, its global checksum is the one of bank 0
define suite
$(1)_dir  := $(BUILD)/$(if $(3),$(3)/)
$(1)_roms := $$(addprefix $$($(1)_dir),$$(addsuffix .gb,$(5)))

# Each test, as a ROM of its own
$$(foreach t,$(5),$$(eval $$(call object,$(1),$(2),$$(t))))
$$(foreach t,$(5),$$(eval $$(call rom,$(1),$$($(1)_dir),$$(t),$(4))))

# The multi-test ROM: the driver, and each test as a block of it
ifneq ($(6),)
$(1)_multi := $(BUILD)/$(6).gb
$(1)_roms  += $$($(1)_multi)
$(1)_seen  :=

$$(eval $$(call object,$(1),$(2),multi))
$$(foreach t,$(5),$$(eval $$(call multi_object,$(1),$(2),$$(t),$$(words $$($(1)_seen))))$$(eval $(1)_seen += $$(t)))

$$($(1)_multi): $(BUILD)/obj/$(1)/multi.o $$(addprefix $(BUILD)/obj/$(1)/,$$(addsuffix .multi.o,$(5)))
	$$(call link,$(4))
	$$(call pad_to,$(7),$(4))
	$$(if $(8),$$(fix_bank0),$$(fix))
endif

ROMS += $$($(1)_roms)
.PHONY: $(1)
$(1): $$($(1)_roms)
endef

# The suites ----------------------------------------------------------------------

tests = $(sort $(basename $(notdir $(wildcard $(1)/[0-9]*.s))))

$(eval $(call suite,cpu_instrs,shell1,cpu_instrs/individual,0,$(call tests,cpu_instrs),cpu_instrs/cpu_instrs,65536,bank0))
$(eval $(call suite,mem_timing,shell1,mem_timing/individual,0,$(call tests,mem_timing),mem_timing/mem_timing,65536,bank0))
$(eval $(call suite,instr_timing,shell1,instr_timing,0,instr_timing,,,))
$(eval $(call suite,mem_timing-2,shell2,mem_timing-2/rom_singles,0xFF,$(call tests,mem_timing-2),mem_timing-2/mem_timing,65536,))
$(eval $(call suite,oam_bug,shell2,oam_bug/rom_singles,0,$(call tests,oam_bug),oam_bug/oam_bug,65536,))
$(eval $(call suite,dmg_sound,shell2,dmg_sound/rom_singles,0,$(call tests,dmg_sound),dmg_sound/dmg_sound,65536,))
$(eval $(call suite,cgb_sound,shell2,cgb_sound/rom_singles,0,$(call tests,cgb_sound),cgb_sound/cgb_sound,65536,))
$(eval $(call suite,interrupt_time,shell2,interrupt_time,0,interrupt_time,,,))
$(eval $(call suite,halt_bug,shell2,,0,halt_bug,,,))

# Targets ----------------------------------------------------------------------------

.PHONY: all check clean

all: $(ROMS)

check: $(ROMS)
	@./compare-roms.sh $(BUILD) $(REFERENCE) $(ROMS:$(BUILD)/%=%)

clean:
	rm -rf $(BUILD)

hardware.inc/hardware.inc:
	@echo "hardware.inc is missing; run: git submodule update --init" >&2
	@exit 2

-include $(wildcard $(BUILD)/obj/*/*.d)
