; Waits for start of LCD blanking period
; Preserved: BC, DE, HL
ConsoleWaitVBL:
	push bc

	; Wait for start of vblank, with
	; timeout in case LY doesn't work
	; or LCD is disabled.
	ld bc, -1250
.wait:
	inc bc
	ld a, b
	or c
	jr z, .timeout
	lda rLY
	cp 144
	jr nz, .wait
.timeout:

	pop bc
	ret

; Initializes text console
ConsoleInit:
	call ConsoleHide

	; CGB-specific inits
	ld a, [wGbId]
	and GB_ID_CGB
	call nz, .initCGB

	; Clear nametable
	ld a, ' '
	call .fillNametable

	; Load tiles
	ld hl, TILEBLOCK0+$200
	ld c, 0
	call .loadTiles
	ld hl, TILEBLOCK0+$A00
	ld c, $FF
	call .loadTiles

	; Init state
	setb wConsolePos, CONSOLE_WIDTH
	setb wConsoleMode, 0
	setb wConsoleScroll, -8
	call ConsoleScrollUp_
	jr ConsoleShow

.fillNametable:
	ld hl, TILEMAP0
	ld b, 4
.fill:
	ld [hl], a
	inc l
	jr nz, .fill
	inc h
	dec b
	jr nz, .fill
	ret

.initCGB:
	; Clear palette
	wreg rBGPI, $80
	ld b, 16
.palette:
	wreg rBGPD, $FF
	wreg rBGPD, $7F
	wreg rBGPD, $00
	wreg rBGPD, $00
	wreg rBGPD, $00
	wreg rBGPD, $00
	wreg rBGPD, $00
	wreg rBGPD, $00
	dec b
	jr nz, .palette

	; Clear attributes
	wreg rVBK, 1
	ld a, 0
	call .fillNametable

	wreg rVBK, 0
	ret

.loadTiles:
	ld de, ASCII
	ld b, 96
.char:
	push bc
	ld b, 8
.row:
	ld a, [de]
	inc de
	xor c
	ld [hli], a
	ld [hli], a
	dec b
	jr nz, .row
	pop bc
	dec b
	jr nz, .char
	ret

; Shows console display
; Preserved: AF, BC, DE, HL
ConsoleShow:
	push af

	; Enable LCD
	call ConsoleWaitVBL
	wreg rLCDC, LCDC_ON | LCDC_BLOCK01 | LCDC_BG_ON
	wreg rSCX, 0
	wreg rBGP, $E4

	jp ConsoleApplyScroll_

; Hides console display by turning LCD off
; Preserved: AF, BC, DE, HL
ConsoleHide:
	push af

	; LCD off
	call ConsoleWaitVBL
	wreg rLCDC, LCDC_OFF | LCDC_BLOCK01 | LCDC_BG_ON

	pop af
	ret

; Changes to normal text mode
; Preserved: BC, DE, HL
ConsoleNormal:
	xor a
	jr ConsoleSetMode

; Changes to inverse text mode
; Preserved: BC, DE, HL
ConsoleInverse:
	ld a, $80

; Changes console mode to A.
; 0: Normal, $80: Inverse
; Preserved: BC, DE, HL
ConsoleSetMode:
	and $80
	ld [wConsoleMode], a
	ret

; Prints char A to console. Will not appear until
; a newline or flush occurs.
; Preserved: AF, BC, DE, HL
ConsolePrint:
	push af

	cp 10
	jr z, ConsoleNewline_

	push hl
	push af
	ld hl, wConsolePos
	ld a, [hli]
	cp LOW(wConsoleBuf)
	jr nz, .notAtEnd

	; Newline if at end of current line. If this
	; were done after writing to buffer, calling
	; ConsoleNewline would print extra newline.
	; Doing it before eliminates this.

	; Ignore any spaces at end of line
	pop af
	cp ' '
	jr z, .ignoreSpace
	call ConsoleNewline
	push af

.notAtEnd:
	pop af
	or [hl]    ; apply current attributes
	dec l      ; hl = wConsolePos
	dec [hl]   ; wConsolePos = wConsolePos - 1
	ld l, [hl] ; hl = position in buffer
	ld [hl], a

.ignoreSpace:
	pop hl
	pop af
	ret

; Displays current line and starts new one
; Preserved: AF, BC, DE, HL
ConsoleNewline:
	push af
ConsoleNewline_:
	call ConsoleWaitVBL
	call ConsoleFlush_
	call ConsoleScrollUp_
	call ConsoleFlush_
	jp ConsoleApplyScroll_

ConsoleScrollUp_:
	push bc
	push hl

	; Scroll up 8 pixels
	ld a, [wConsoleScroll]
	add 8
	ld [wConsoleScroll], a

	; Start new clear line
	ld a, ' '
	ld hl, wConsoleBuf + CONSOLE_WIDTH - 1
	ld b, CONSOLE_WIDTH
.clear:
	ld [hld], a
	dec b
	jr nz, .clear
	setb wConsolePos, LOW((wConsoleBuf + CONSOLE_WIDTH))

	pop hl
	pop bc
	ret

; Displays current line's contents without scrolling.
; Preserved: A, BC, DE, HL
ConsoleFlush:
	push af
	call ConsoleWaitVBL
	call ConsoleFlush_
ConsoleApplyScroll_:
	ld a, [wConsoleScroll]
	sub 136
	sta rSCY
	pop af
	ret

ConsoleFlush_:
	push de
	push hl

	; Address of row in nametable
	ld a, [wConsoleScroll]
	ld l, a
	ld h, (HIGH(TILEMAP0)) >> 2
	add hl, hl
	add hl, hl

	; Copy line
	ld de, wConsoleBuf + CONSOLE_WIDTH
.copy:
	dec e
	ld a, [de]
	ld [hli], a
	ld a, e
	cp LOW(wConsoleBuf)
	jr nz, .copy

	pop hl
	pop de
	ret

ASCII:
	INCLUDE "console_font.inc"
