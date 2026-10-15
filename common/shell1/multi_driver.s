; Driver of the multi-test ROM: runs the tests stored in the blocks of banks
; 1 and up, one after the other, and reports how many failed.
;
; Reconstructed: the source of the driver was not part of the released
; sources. It was written to assemble to the code of the released ROM, and
; the names and comments are guessed.
;
; The driver runs from bank 0. A test is built with BUILD_MULTI and
; MULTI_TEST (its number) defined, which stores it in a block of $1000 bytes
; at $4000 + (MULTI_TEST & 3) * $1000 in bank 1 + MULTI_TEST / 4. To run it,
; the driver copies the block to $C000 and jumps there; when the test exits,
; it jumps to $3FFD, which comes back to the driver with its result in A.

DEF MULTI_DRIVER = 1

; The tests use the RAM at $D800 and $FF80: the driver keeps its variables
; below them.
DEF bss = $D600
DEF dp = $FFC0

INCLUDE "shell.inc"
INCLUDE "apu.s"
INCLUDE "cpu_speed.s"

; The tests can leave SP anywhere, so the driver has a stack of its own and
; saves SP while a test runs.
DEF stack_size = $40
DEF stack_bottom = bss
DEF bss = bss+stack_size
DEF stack_top = bss
DEF saved_sp = bss+0
DEF bss = bss+2

; The tests' way back, at a fixed address
PUSHS
SECTION "return from test", ROM0[$3FFD]
     jp   main.test_exited
POPS

reset:
     jp   std_reset

report_byte:
     ret

main:
     ld   sp,stack_top
     ld   b,0       ; test number
     ld   c,0       ; failed tests

.next_test:
     ; Select the bank of the test, four to a bank
     ld   a,b
     srl  a
     srl  a
     inc  a
     ld   [rROMB],a

     ; DE = address of its block
     ld   a,b
     swap a
     and  $30
     or   $40
     ld   d,a
     ld   e,0

     ; The blocks end at the first one that doesn't start with a JP
     ld   a,[de]
     cp   $C3
     jp   nz,.finished

     push bc
     call print_test_number

     ; Run it
     ld   hl,sp+0
     ld   a,l
     ld   [saved_sp],a
     ld   a,h
     ld   [saved_sp+1],a
     ld   h,d
     ld   l,e
     jp   copy_to_wram_then_run

     ; Back from the test at $3FFD, with its result in A
.test_exited:
     ld   d,a
     ld   a,[saved_sp]
     ld   l,a
     ld   a,[saved_sp+1]
     ld   h,a
     ld   sp,hl
     ld   a,d
     pop  bc
     call report_test
     inc  b
     jp   .next_test

.finished:
     call print_newline
     call print_newline
     ld   a,c
     cp   0
     jr   nz,.failed
     print_str "Passed all tests"
     jr   .done

.failed:
     print_str "Failed "
     ld   a,c
     call print_dec
     print_str " tests."

.done:
     call print_newline

     ; Beep
     call sound_off
     call sound_on
     wreg rAUD1LEN,$80
     wreg rAUD1ENV,$F1
     wreg rAUD1LOW,$00
     ld   c,10
:    wreg rAUD1HIGH,$87
     delay_msec 250
     dec  c
     jr   nz,:-
.forever:
     jp   .forever


; Prints number of test B
print_test_number:
     ld   a,b
     inc  a
     call print_dec2
     call console_flush
     ret


; Reports result A of test B: ok, or A in inverse. Counts the failure in C.
report_test:
     ld   d,a
     call cpu_norm
     print_str ":"
     ld   a,d
     cp   0
     jr   nz,.failed
     print_str "ok  "
     call console_flush
     ret

.failed:
     inc  c
     ld   a,b
     call play_byte
     ld   a,d
     call play_byte
     call console_inverse
     ld   a,d
     call print_dec2
     call console_normal
     print_str "  "
     call console_flush
     ret

INCLUDE "shell_end.inc"
