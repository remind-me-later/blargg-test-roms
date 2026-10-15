; Tests timing of accesses made by
; memory write instructions

DEF TEST_NAME EQUS "02-write_timing"
DEF ROM_NAME EQUS "02-WRITE_TIMING"
INCLUDE "shell.inc"
INCLUDE "tima_64.s"

instructions:
     ; last value is time of write
     db $36, $FF, $00, 3 ; LD   (HL),n
     db $70, $00, $00, 2 ; LD   (HL),B
     db $71, $00, $00, 2 ; LD   (HL),C
     db $72, $00, $00, 2 ; LD   (HL),D
     db $73, $00, $00, 2 ; LD   (HL),E
     db $74, $00, $00, 2 ; LD   (HL),H
     db $75, $00, $00, 2 ; LD   (HL),L
     db $77, $00, $00, 2 ; LD   (HL),A
     db $02, $00, $00, 2 ; LD   (BC),A
     db $12, $00, $00, 2 ; LD   (DE),A
     db $22, $00, $00, 2 ; LD   (HL+),A
     db $32, $00, $00, 2 ; LD   (HL-),A
     db $E2, $00, $00, 2 ; LDH  (C),A
     db $E0, LOW(tima_64), $00, 3 ; LDH  (n),A
     db $EA, LOW(tima_64), HIGH(tima_64), 4 ; LD   (nn),A
instructions_end:

main:
     call init_tima_64
     set_test 0

     ; Test instructions
     ld   hl,instructions
:    call .test_instr
     cp   [hl]
     call nz,.print_failed
     inc  hl
     ld   a,l
     cp   LOW(instructions_end)
     jr   nz,:-

     jp   tests_done

.print_failed:
     push hl
     ld   b,a
     ld   c,[hl]
     dec  hl
     dec  hl
     dec  hl
     ld   a,[hl]
     call print_hex
     print_str ":"
     ld   a,b
     call print_dec
     print_str "-"
     ld   a,c
     call print_dec
     print_str " "
     pop  hl
     set_test 1
     ret

; Tests instruction
; HL -> 3-byte instruction
; HL <- HL + 3
.test_instr:
     ; Copy instr
     ld   a,[hli]
     ld   [instr+0],a
     ld   a,[hli]
     ld   [instr+1],a
     ld   a,[hli]
     ld   [instr+2],a
     push hl

     ; Test for writes on each cycle
     ld   b,0
:    push bc
     call .time_write
     pop  bc
     cp   LOW(tima_64)
     jr   z,.no_write
     cp   HIGH(tima_64)
     jr   z,.no_write
     jr   .found
.no_write:
     inc  b
     ld   a,b
     cp   10
     jr   nz,:-
     ld   b,0

.found:
     ld   a,b
     pop  hl
     ret

; Tests for write
; B -> which cycle to test
; A <- timer value after test
.time_write:
     call sync_tima_64
     ld   a,13
     sub  b
     call delay_a_20_cycles
     ld   hl,tima_64
     ld   bc,tima_64
     ld   de,tima_64
     ld   a,LOW(tima_64)
instr:
     nop
     nop
     nop
     delay 32
     ld   a,[tima_64]
     ret

INCLUDE "shell_end.inc"
