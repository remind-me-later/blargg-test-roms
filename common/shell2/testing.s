SetTest_:
	pop  hl
	push hl
	push af
	inc  hl
	inc  hl
	ld   a,[hli]
	ld   [wTestCode],a
	ld   a,l
	ld   [wTestName],a
	ld   a,h
	ld   [wTestName+1],a
	pop  af
	ret

; Initializes testing module
InitTesting:
	set_test $FF
	call InitCRC
	ret

; Reports "Passed", then exits with code 0
TestsPassed:
	call PrintNewline
	print_str "Passed"
	ld   a,0
	jp   Exit

; Reports "Done" if set_test has never been used,
; "Passed" if set_test 0 was last used, or
; failure if set_test n was last used.
TestsDone:
	ld   a,[wTestCode]
	inc  a
	jr   z,.done
	dec  a
	jr   z,TestsPassed
	jr   TestFailed
.done:
	print_str "Done"
	ld   a,0
	jp   Exit

; Reports current error text and exits with result code
TestFailed:
	ld   a,[wTestName]
	ld   l,a
	ld   a,[wTestName+1]
	ld   h,a
	ld   a,[hl]
	or   a
	jr   z,.noText
	call PrintNewline
	call PrintStrHL
	call PrintNewline
.noText:
	ld   a,[wTestCode]
	cp   $FF       ; if a = $FF then a = 1
	jr   nz,.exit
	ld   a,1
.exit:
	jp   Exit

; Prints checksum as 8-character hex value
; Preserved: AF, BC, DE, HL
PrintCRC:
	push af

	; Must read checksum entirely before printing,
	; since printing updates it.
	lda  hChecksum
	cpl
	push af

	lda  hChecksum+1
	cpl
	push af

	lda  hChecksum+2
	cpl
	push af

	lda  hChecksum+3
	cpl

	call PrintHex
	pop  af
	call PrintHex
	pop  af
	call PrintHex
	pop  af
	call PrintA

	pop  af
	ret

CheckCRC_:
	lda  hChecksum+0
	cp   e
	jr   nz,.failed

	lda  hChecksum+1
	cp   d
	jr   nz,.failed

	lda  hChecksum+2
	cp   c
	jr   nz,.failed

	lda  hChecksum+3
	cp   b
	jr   nz,.failed

	jp   ResetCRC

.failed:
	call PrintCRC
	jp   TestFailed

ChecksumMem_:
.loop:
	ld   a,[hli]
	call UpdateCRC
	dec  bc
	ld   a,b
	or   c
	jr   nz,.loop
	ret
