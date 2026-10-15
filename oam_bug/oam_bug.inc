; Included at the beginning of all the OAM bug tests.
;
; Reconstructed: the file was not part of the released sources. It was
; written to assemble to the code that precedes the tests in the released
; ROMs, and the names are guessed.

INCLUDE "shell.inc"
INCLUDE "ppu.s"

; Object attribute memory
DEF OAM_START EQU $FE00

; Stack pointer saved by save_sp
DEF saved_sp = dp+0
DEF dp = dp+2

; Saves SP, for tests that change it
MACRO save_sp
     ld   [saved_sp],sp
ENDM

; Restores SP saved by save_sp
; Preserved: AF, BC, DE
MACRO restore_sp
     lda  saved_sp
     ld   l,a
     lda  saved_sp+1
     ld   h,a
     ld   sp,hl
ENDM


; Turns LCD on
enable_lcd:
     wreg rLCDC,LCDC_ON | LCDC_BG_ON
     ret


; Turns LCD off, in vblank, and waits for it to settle
; Preserved: AF
disable_lcd:
     call wait_vbl
     wreg rLCDC,0
     delay_msec 20
     ret


; Fills OAM with the sequence $0C, $0D, ...
; Preserved: BC, DE, HL
fill_oam:
     ld   a,$0C
     push hl
     ld   hl,OAM_START
.fill:
     ld   [hl],a
     inc  a
     inc  l
     bit  7,l
     jr   z,.fill
     bit  5,l
     jr   z,.fill
     pop  hl
     ret


; Compares OAM with the sequence written by fill_oam.
; Returns Z set if it's unchanged.
; Preserved: BC, DE
cp_oam:
     ld   a,$0C
     ld   hl,OAM_START
.compare:
     cp   [hl]
     ret  nz
     inc  a
     inc  l
     bit  7,l
     jr   z,.compare
     bit  5,l
     jr   z,.compare
     xor  a
     ret


; Prints OAM, 16 bytes per line with the address at the beginning, as the
; difference from the sequence written by fill_oam, or -- if unchanged.
print_oam:
     ld   a,$0C
     ld   hl,OAM_START
.next:
     push af
     ld   a,l
     and  $0F
     jr   nz,.value
     or   l
     jr   z,.address
     call print_newline
.address:
     ld   a,l
     call print_a
.value:
     pop  af
     push af
     cp   [hl]
     jr   z,.unchanged
     ld   a,[hl]
     sub  $0C
     call print_a
     jr   .step
.unchanged:
     push hl
     print_str "-- "
     pop  hl
.step:
     pop  af
     inc  a
     inc  l
     bit  7,l
     jr   z,.next
     bit  5,l
     jr   z,.next
     call print_newline
     ret
