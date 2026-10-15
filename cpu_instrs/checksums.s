; Multiple checksum table handling

PUSHS UNION "Checksum variables", WRAMX[wShellVariablesEnd], BANK[1]
wNextChecksum:  dw
wChecksumVariablesEnd:
POPS

; If PRINT_CHECKSUMS is defined, checksums are printed
; rather than compared.

; Initializes multiple checksum handler to use checksums
; table (defined by user).
; Preserved: BC, DE, HL
ChecksumsInit:
	ld   a,LOW(Checksums)
	ld   [wNextChecksum],a
	ld   a,HIGH(Checksums)
	ld   [wNextChecksum+1],a
	ret

; Compares current checksum with next checksum in
; list. Z if they match, NZ if not.
; Preserved: BC, DE, HL
ChecksumsCompare:
IF DEF(PRINT_CHECKSUMS)
	lda  hChecksum+3
	push af
	lda  hChecksum+2
	push af
	lda  hChecksum+1
	push af
	lda  hChecksum+0
	push af

	ld   a,[wNextChecksum]
	inc  a
	ld   [wNextChecksum],a
	sub  LOW(Checksums)+1
	and  $03
	ld   a,','
	jr   nz,.print
	print_str NEWLINE,'.',"byte"
	ld   a,' '
.print:
	call PrintChar

	pop  af
	call .printByte
	pop  af
	call .printByte
	pop  af
	call .printByte
	ld   a,'$'
	call PrintChar
	pop  af
	call PrintHex

	xor  a
	ret

.printByte:
	push af
	ld   a,'$'
	call PrintChar
	pop  af
	call PrintHex
	ld   a,','
	call PrintChar
	ret
ELSE

	push bc
	push de
	push hl
	ld   a,[wNextChecksum]
	ld   l,a
	ld   a,[wNextChecksum+1]
	ld   h,a
	ld   de,hChecksum
	ld   b,0
.compare:
	ld   a,[de]
	xor  [hl]
	or   b
	ld   b,a
	inc  hl
	inc  e
	ld   a,e
	cp   LOW((hChecksum+4))
	jr   nz,.compare
	ld   a,l
	ld   [wNextChecksum],a
	ld   a,h
	ld   [wNextChecksum+1],a

	ld   a,b
	cp   0
	pop  hl
	pop  de
	pop  bc
	ret
ENDC
