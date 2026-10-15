; Waits for LCD blanking period
; Preserved: BC, DE, HL
WaitVBL:
	; Return if off
	lda  rLCDC
	rla
	ret  nc

	; Wait for start of vblank
.wait:
	lda  rLY
	cp   144
	jr   nz,.wait

	ret
