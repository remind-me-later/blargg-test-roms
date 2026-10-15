; Tests what the halt bug does to the instruction after HALT, for each
; combination of IE and IF that makes HALT end at once or not at all.
; Prints IE IF, then IF and DE after the second HALT.
;
; Reconstructed: no source of this test was published. It was written to
; assemble to the code of the released ROM, and the comments are guessed.

DEF TEST_NAME EQUS "\"halt bug\""
INCLUDE "shell.inc"
INCLUDE "ppu.s"

main:
     ld   bc,$0000
     print_str "IE IF IF DE"
     call print_newline

     ; Needs the LCD on
     call wait_vbl
     wreg rLCDC,LCDC_ON | LCDC_BLOCK01 | LCDC_BG_ON

     ld   bc,$0110
     call test
     ld   bc,$0100
     call test
     ld   bc,$0101
     call test
     ld   bc,$1100
     call test
     ld   bc,$1110
     call test
     ld   bc,$1111
     call test
     ld   bc,$E100
     call test
     ld   bc,$E1E0
     call test
     ld   bc,$E1E1
     call test

     check_crc $B29060A6
     jp   tests_passed


; Does a HALT with IE = B and IF = C, then another with the instruction
; after it as LD DE,$0C04, and prints IE, IF, then IF and DE
test:
     call print_b
     call print_c

     di
     wreg rIE,$01
     wreg rIF,$00
     halt
     nop

     ld   a,b
     ldh  [rIE],a
     ld   de,$1234
     ld   a,c
     ldh  [rIF],a
     nop
     nop
     halt
     ld   de,$0C04
     nop

     delay_msec 100
     lda  rIF
     call print_a
     call print_de
     call print_newline
     ret

INCLUDE "shell_end.inc"
