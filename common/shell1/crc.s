; CRC-32 checksum calculation


; Initializes checksum module. Might initialize tables
; in the future.
InitCRC:
	jr ResetCRC


; Clears CRC
; Preserved: BC, DE, HL
ResetCRC:
	ld a, $FF
	sta hChecksum+0
	sta hChecksum+1
	sta hChecksum+2
	sta hChecksum+3
	ret


; Updates current checksum with byte A
; Preserved: AF, BC, DE, HL
; Time: 237 cycles average
UpdateCRC:
	; 65 cycles + 8*cycles per bit
	; min cycles per bit: 14
	; max cycles per bit: 29
	push af
	push bc
	push de
	push hl

	ld hl, hChecksum+3
	ld b, [hl]
	dec l
	ld c, [hl]
	dec l
	ld d, [hl]
	dec l
	xor [hl]

	ld h, 8
.bit:
	srl b
	rr c
	rr d
	rra
	jr nc, .nextBit
	ld e, a
	ld a, b
	xor $ED
	ld b, a
	ld a, c
	xor $B8
	ld c, a
	ld a, d
	xor $83
	ld d, a
	ld a, e
	xor $20
.nextBit:
	dec h
	jr nz, .bit

	ld h, HIGH(hChecksum)
	ld [hli], a
	ld [hl], d
	inc l
	ld [hl], c
	inc l
	ld [hl], b

	pop hl
	pop de
	pop bc
	pop af
	ret
