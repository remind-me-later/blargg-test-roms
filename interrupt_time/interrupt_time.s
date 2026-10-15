; Tests interrupt handling time for slow and fast
; CPU. First value is CPU speed (0=slow, 1=fast),
; second is number of cycles taken by interrupt.
; Should take 13 cycles at either speed.
DEF REQUIRE_CGB = 1
DEF TEST_NAME EQUS "interrupt time"

INCLUDE "shell.inc"
INCLUDE "cpu_speed.s"
INCLUDE "timer.s"
INCLUDE "apu.s"

; $58: JP $DEC3
; $DEC3: RET
DEF sint = $DEC3

main:
     call init_timer

     ld   d,0
     call test_interrupt
     ld   d,8
     call test_interrupt
     call cpu_fast
     ld   d,0
     call test_interrupt
     ld   d,8
     call test_interrupt

     ; The released ROM expects this checksum; the source said $C86CC74D.
     check_crc $B511F33D
     jp   tests_passed

test_interrupt:
     call get_cpu_speed
     call print_a
     call print_d

     ld   a,$C9     ; RET
     ld   [sint],a

     wreg rIE,$08
     wreg rIF,$00
     call start_timer
     ei
     ld   a,d
     ld   [rIF],a    ; $00 = 0 clocks, $08 = 13 clocks
     di
     call stop_timer
     sub  3+4       ; instruction overhead
     call print_a
     call print_newline

     ret

; RST handler that matches the one in my devcart
PUSHS
SECTION "vector 1", ROM0[$58]
     jp   $DEC3
POPS

INCLUDE "shell_end.inc"
