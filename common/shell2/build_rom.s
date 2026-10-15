; Build as GB ROM

;;;; GB ROM header

; Reserve space for the RST handlers
SECTION "RST area", ROM0[$70]
	ds   $90,0

SECTION "header", ROM0[$100]
	; GB header read by bootrom
	nop
	jp   Reset

	; Nintendo logo required for proper boot
	db $CE,$ED,$66,$66,$CC,$0D,$00,$0B
	db $03,$73,$00,$83,$00,$0C,$00,$0D
	db $00,$08,$11,$1F,$88,$89,$00,$0E
	db $DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	db $BB,$BB,$67,$63,$6E,$0E,$EC,$CC
	db $DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	; Internal name
IF DEF(ROM_NAME)
	db "{ROM_NAME}"
ENDC
	ds $143 - @, 0

	; CGB/DMG requirements
IF DEF(REQUIRE_CGB)
	db $C0
ELIF DEF(REQUIRE_DMG)
	db $00
ELSE
	db $80
ENDC
	ds $147 - @, 0

	db CART_TYPE
IF DEF(MULTI_DRIVER)
	db 1    ; 64K ROM
ELSE
	db 0    ; 32K ROM
ENDC
	db RAM_SIZE
	ds $150 - @, 0    ; rgbfix sets the checksums

; Keep unused space filled up to the copy routine
SECTION "unused", ROM0[$150]
	ds   $2150-$150,ROM_FILL

;;;; Shell

DEF NEED_CONSOLE EQU 1
INCLUDE "shell.s"
