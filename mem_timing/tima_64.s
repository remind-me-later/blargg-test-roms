; Timer that's incremented every 64 cycles

; Initializes timer for use by SyncTIMA64
InitTIMA64:
	wreg rTMA, 0
	wreg rTAC, $07
	ret

; Synchronizes to timer
SyncTIMA64:
	push af
	push hl

	ld a, 0
	ld hl, rTIMA
	ld [hl], a
.coarse:
	or [hl]
	jr z, .coarse

.fine:
	delay 65-12
	xor a
	ld [hl], a
	or [hl]
	delay 4
	jr z, .fine

	pop hl
	pop af
	ret

; Read from this to get count that's incremented
; every 64 cycles.
DEF tima_64 EQU rTIMA
