; Included at the beginning of all the OAM bug tests.
;
; Ported from source/common/oam_bug.inc of oam_bug-2.zip, which is Blargg's:
; http://blargg.8bitalley.com/parodius/gb-tests/oam_bug-2.zip, as the Wayback
; Machine archived it on 2016-07-31. The zip of the ROMs of this suite
; (oam_bug.zip) did not have it. The names are this repository's and the
; comments Blargg's, except the one on the variable. It assembles to the
; code that precedes the tests in the released ROMs.

INCLUDE "shell.inc"
INCLUDE "ppu.s"

DEF OAM_FILL EQU $0C
DEF OAM_START EQU $FE00

; The variables of the tests, and of the driver of a multi-test ROM, share
; this section (and so, this RAM): the driver saves its own while a test runs.
PUSHS UNION "Test HRAM variables", HRAM[hShellVariablesEnd]
hSavedSp:       dw
POPS

MACRO save_sp
	ld [hSavedSp], sp
ENDM

MACRO restore_sp
	lda hSavedSp
	ld l, a
	lda hSavedSp+1
	ld h, a
	ld sp, hl
ENDM


; Enables LCD rendering. If it was disabled, this
; results in being synchronized to refresh.
EnableLCD:
	wreg rLCDC, LCDC_ON | LCDC_BG_ON
	ret


; Disables LCD rendering
DisableLCD:
	call WaitVBL
	wreg rLCDC, 0
	delay_msec 20
	ret


; Fills OAM with A,A+1...A+$9E
; Preserved: BC, DE, HL
FillOAM:
	ld a, OAM_FILL
	push hl
	ld hl, OAM_START
.fill:
	ld [hl], a
	inc a
	inc l
	bit 7, l
	jr z, .fill
	bit 5, l
	jr z, .fill
	pop hl
	ret


; Compares OAM with A,A+1...A+$9E.
; Z if same, NZ if different
; Preserved: BC, DE, HL
CpOAM:
	ld a, OAM_FILL
	ld hl, OAM_START
.compare:
	cp [hl]
	ret nz
	inc a
	inc l
	bit 7, l
	jr z, .compare
	bit 5, l
	jr z, .compare
	xor a
	ret


; Prints contents of OAM
PrintOAM:
	ld a, OAM_FILL
	ld hl, OAM_START
.loop:
	push af
	ld a, l
	and $0F
	jr nz, .value
	or l
	jr z, .address
	call PrintNewline
.address:
	ld a, l
	call PrintA
.value:
	pop af

	push af
	cp [hl]
	jr z, .unchanged
	ld a, [hl]
	sub OAM_FILL
	call PrintA
	jr .skip
.unchanged:
	push hl
	print_str "-- "
	pop hl
.skip:
	pop af
	inc a

	inc l
	bit 7, l
	jr z, .loop
	bit 5, l
	jr z, .loop
	call PrintNewline
	ret
