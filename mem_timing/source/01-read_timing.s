; Tests timing of accesses made by
; memory read instructions

DEF TEST_NAME EQUS "01-read_timing"
INCLUDE "shell.inc"
INCLUDE "tima_64.s"

instructions:
     ; last value is time of read
     db $B6, $00, $00, 2 ; OR   (HL)
     db $BE, $00, $00, 2 ; CP   (HL)
     db $86, $00, $00, 2 ; ADD  (HL)
     db $8E, $00, $00, 2 ; ADC  (HL)
     db $96, $00, $00, 2 ; SUB  (HL)
     db $9E, $00, $00, 2 ; SBC  (HL)
     db $A6, $00, $00, 2 ; AND  (HL)
     db $AE, $00, $00, 2 ; XOR  (HL)
     db $46, $00, $00, 2 ; LD   B,(HL)
     db $4E, $00, $00, 2 ; LD   C,(HL)
     db $56, $00, $00, 2 ; LD   D,(HL)
     db $5E, $00, $00, 2 ; LD   E,(HL)
     db $66, $00, $00, 2 ; LD   H,(HL)
     db $6E, $00, $00, 2 ; LD   L,(HL)
     db $7E, $00, $00, 2 ; LD   A,(HL)
     db $F2, $00, $00, 2 ; LDH  A,(C)
     db $0A, $00, $00, 2 ; LD   A,(BC)
     db $1A, $00, $00, 2 ; LD   A,(DE)
     db $2A, $00, $00, 2 ; LD   A,(HL+)
     db $3A, $00, $00, 2 ; LD   A,(HL-)
     db $F0, LOW(tima_64), $00, 3 ; LDH  A,($00)
     db $FA, LOW(tima_64), HIGH(tima_64), 4 ; LD   A,($0000)

     db $CB, $46, $00, 3 ; BIT  0,(HL)
     db $CB, $4E, $00, 3 ; BIT  1,(HL)
     db $CB, $56, $00, 3 ; BIT  2,(HL)
     db $CB, $5E, $00, 3 ; BIT  3,(HL)
     db $CB, $66, $00, 3 ; BIT  4,(HL)
     db $CB, $6E, $00, 3 ; BIT  5,(HL)
     db $CB, $76, $00, 3 ; BIT  6,(HL)
     db $CB, $7E, $00, 3 ; BIT  7,(HL)
instructions_end:

main:
     call init_tima_64
     set_test 0

     ; Test instructions
     ld   hl,instructions
:    call .time_instr
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
     ld   a,[hli]
     cp   $CB
     jr   nz,:+
     call print_a
     ld   a,[hl]
:    call print_hex
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
.time_instr:
     ; Copy instr
     ld   a,[hli]
     ld   [instr+0],a
     ld   a,[hli]
     ld   [instr+1],a
     ld   a,[hli]
     ld   [instr+2],a
     push hl

     ; Find result when access doesn't occur
     ld   b,0
     call .time_access
     ld   c,a

     ; Test for accesses on each cycle
     ld   b,0
:    push bc
     call .time_access
     pop  bc
     cp   c
     jr   nz,.found
     inc  b
     ld   a,b
     cp   10
     jr   nz,:-
     ld   b,0

.found:
     ld   a,b
     pop  hl
     ret

; Tests for read
; B -> which cycle to test
; A <- timer value after test
.time_access:
     call sync_tima_64
     ld   a,9
     sub  b
     call delay_a_20_cycles
     xor  a    ; clear flags
     ld   hl,tima_64
     ld   [hl],$7F
     ld   bc,tima_64
     ld   de,tima_64
     ld   a,$7F
instr:
     nop
     nop
     nop

     ; Add all registers together to yield
     ; unique value that differs based on
     ; read occurring before or after tima_64
     ; increments.
     push af
     add  hl,bc
     add  hl,de
     pop  de
     add  hl,de
     ld   a,h
     add  l
     ret

INCLUDE "shell_end.inc"
