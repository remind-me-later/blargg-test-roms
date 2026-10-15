; Driver of the multi-test ROM: runs the tests stored in the blocks of banks
; 1 and up, one after the other, and reports the first that failed.
;
; Reconstructed: the source of the driver was not part of the released
; sources. It was written to assemble to the code of the released ROM, and
; the names and comments are guessed.
;
; The driver runs from bank 0. A test is built with BUILD_MULTI and
; MULTI_TEST (its number) defined, which stores it in a block of $1000 bytes
; at $4000 + (MULTI_TEST & 3) * $1000 in bank 1 + MULTI_TEST / 4. To run it,
; the driver saves its state in the cartridge RAM, copies the block to $C000
; and jumps there; when the test exits, it jumps to $3F00, which restores the
; state and returns to the driver with the result of the test in A.

DEF ROM_NAME EQUS "\"OAM_BUG\""
DEF TEST_NAME EQUS "\"oam_bug\""
DEF MULTI_DRIVER = 1

INCLUDE "shell.inc"
INCLUDE "apu.s"
INCLUDE "cpu_speed.s"

; Variables
DEF first_failed = dp+0     ; number of the first test that failed, or 0
DEF test_number = dp+1      ; number of the running test, from 0
DEF dp = dp+2

; Cartridge RAM, where the state of the driver is kept while a test runs: SP,
; then the RAM from nv_ram_base and the direct page, which the tests clear.
DEF saved_sp = $BC00
DEF saved_state = $BC02
DEF state_size = $9C
DEF dp_state_size = 6

; The way back from the tests, at a fixed address
PUSHS
SECTION "return from test", ROM0[$3F00]
     jp   test_exited
POPS

reset:
     jp   std_reset

main:
     ld   sp,$C000
     setb first_failed,0
     setb test_number,-1
     
.next_test:
     lda  test_number
     inc  a
     sta  test_number
     
     ; Select the bank of the test, four to a bank
     srl  a
     srl  a
     inc  a
     ld   [rROMB],a
     
     ; DE = address of its block
     lda  test_number
     swap a
     and  $30
     or   $40
     ld   d,a
     ld   e,0
     
     ; The blocks end at the first one that doesn't start with a JP
     ld   a,[de]
     cp   $C3
     jp   nz,.finished
     
     call print_test_number
     call run_test
     call report_test
     jp   .next_test

.finished:
     call print_newline
     lda  first_failed
     or   a
     jr   z,.all_passed
     call print_newline
     print_str "Run failed tests",newline
     print_str "individually for",newline
     print_str "more details.",newline
     
.all_passed:
     ; Beep
     call sound_off
     call sound_on
     wreg rAUD1LEN,$80
     wreg rAUD1ENV,$F1
     wreg rAUD1LOW,$00
     ld   c,5
:    wreg rAUD1HIGH,$87
     delay_msec 250
     dec  c
     jr   nz,:-
     
     ; Exit with the number of the first test that failed
     lda  first_failed
     ld   [test_code],a
     jp   tests_done


; Runs the test whose block is at DE
run_test:
     ; Save SP, as the test will use its own stack
     ld   hl,sp+0
     ld   a,l
     ld   [saved_sp],a
     ld   a,h
     ld   [saved_sp+1],a
     
     ; Save the variables of the driver
     push de
     ld   hl,saved_state
     ld   bc,state_size
     ld   de,nv_ram_base
     call copy_bytes
     ld   bc,dp_state_size
     ld   de,dp_base
     call copy_bytes
     pop  hl
     
     ; Copy the block and run it
     ld   c,$10
     jp   copy_to_wram_then_run

     ; Back from the test at $3F00, with its result in A
test_exited:
     ld   d,a
     ld   a,[saved_sp]
     ld   l,a
     ld   a,[saved_sp+1]
     ld   h,a
     ld   sp,hl
     ld   a,d
     push af
     
     ; Restore the variables of the driver
     ld   de,saved_state
     ld   bc,state_size
     ld   hl,nv_ram_base
     call copy_bytes
     ld   bc,dp_state_size
     ld   hl,dp_base
     call copy_bytes
     
     call cpu_norm
     pop  af
     ret


; Copies BC bytes from DE to HL
copy_bytes:
     ld   a,[de]
     inc  de
     ld   [hli],a
     dec  bc
     ld   a,b
     or   c
     jr   nz,copy_bytes
     ret


; Prints the number of the test
print_test_number:
     lda  test_number
     inc  a
     call print_dec2
     call console_flush
     ret


; Reports result A of the test: ok, or A in inverse. Remembers the first
; failure.
report_test:
     print_str ":"
     or   a
     jr   nz,.failed
     print_str "ok  "
     call console_flush
     ret
     
.failed:
     push af
     lda  first_failed
     or   a
     jr   nz,:+
     lda  test_number
     inc  a
     sta  first_failed
:    lda  test_number
     inc  a
     call play_byte
     ld   a,d
     call play_byte
     call console_inverse
     pop  af
     call print_dec2
     call console_normal
     print_str "  "
     call console_flush
     ret

INCLUDE "shell_end.inc"
