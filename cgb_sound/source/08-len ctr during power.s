; On CGB, length counters are reset when powered up.
; On DMG, they are unaffected, and not clocked.

;DEF REQUIRE_DMG = 1
;DEF REQUIRE_CGB = 1
DEF TEST_NAME EQUS "\"08-len ctr during power\""
INCLUDE "shell.inc"
INCLUDE "apu.s"

enable_len_ctrs:
     wreg rAUD2ENV,8
     wreg rAUD2HIGH,$C0
     wreg rAUD1ENV,8
     wreg rAUD1HIGH,$C0
     wreg rAUD3ENA,$80
     wreg rAUD3HIGH,$C0
     wreg rAUD4ENV,8
     wreg rAUD4GO,$C0
     ret

main:
     call sync_apu

     ld   a,0
     call fill_apu_regs

     ; Load length counters
     wreg rAUD4LEN,-$33
     wreg rAUD3LEN,-$44
     wreg rAUD1LEN,-$11
     wreg rAUD2LEN,-$22

     delay_clocks 8192
     call enable_len_ctrs

     ; Power down. Comment out to see what would
     ; happen if length counters did run.
     wreg rAUDENA,AUDENA_OFF

     ; Try to enable length counters
     call enable_len_ctrs

     ; Give plenty of time for them to be clocked
     delay_msec 250

     ; Power back on and wait a bit longer
     wreg rAUDENA,AUDENA_ON
     ;call enable_len_ctrs ; can't do this here
     delay_clocks 2048

     ; Get values from length counters
     wreg rAUD2ENV,8
     wreg rAUD2HIGH,$C0
     ld   a,$02
     call get_len_a
     push af

     wreg rAUD1ENV,8
     wreg rAUD1HIGH,$C0
     ld   a,$01
     call get_len_a
     push af

     wreg rAUD3ENA,$80
     wreg rAUD3HIGH,$C0
     ld   a,$04
     call get_len_a
     push af

     wreg rAUD4ENV,8
     wreg rAUD4GO,$C0
     ld   a,$08
     call get_len_a

     ; Print them
     call print_a
     pop  af
     call print_a
     pop  af
     call print_a
     pop  af
     call print_a

     check_crc_dmg_cgb $32F0CFBB,$3CF589B4
     jp tests_passed

INCLUDE "shell_end.inc"
