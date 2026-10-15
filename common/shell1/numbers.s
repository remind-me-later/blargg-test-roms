; Printing of numeric values

; Prints value of indicated register/pair
; as 2/4 hex digits, followed by a space.
; Updates checksum with printed values.
; Preserved: AF, BC, DE, HL

PrintRegs:
	call PrintAF
	call PrintBC
	call PrintDE
	call PrintHL
	call PrintNewline
	ret

PrintA:
	push af
PrintA_:
	call PrintHex
	ld a, ' '
	call wPrintCharNoCrc
	pop af
	ret

PrintAF:
	push af
	call PrintHex
	pop af
PrintF:
	push bc
	push af
	pop bc
	call PrintC
	pop bc
	ret

PrintB:
	push af
	ld a, b
	jr PrintA_

PrintC:
	push af
	ld a, c
	jr PrintA_

PrintD:
	push af
	ld a, d
	jr PrintA_

PrintE:
	push af
	ld a, e
	jr PrintA_

PrintH:
	push af
	ld a, h
	jr PrintA_

PrintL:
	push af
	ld a, l
	jr PrintA_

PrintBC:
	push af
	push bc
PrintBC_:
	ld a, b
	call PrintHex
	ld a, c
	pop bc
	jr PrintA_

PrintDE:
	push af
	push bc
	ld b, d
	ld c, e
	jr PrintBC_

PrintHL:
	push af
	push bc
	ld b, h
	ld c, l
	jr PrintBC_


; Prints A as two hex chars and updates checksum
; Preserved: BC, DE, HL
PrintHex:
	call UpdateCRC
PrintHexNoCRC:
	push af
	swap a
	call .nibble
	pop af

.nibble:
	and $0F
	cp 10
	jr c, .print
	add 7
.print:
	add '0'
	jp wPrintCharNoCrc


; Prints char_nz if Z flag is clear,
; char_z if Z flag is set.
; Preserved: AF, BC, DE, HL
MACRO print_nz
	push af
	ld a, \1
	jr nz, PrintNZ\@
	ld a, \2
PrintNZ\@:
	call PrintChar
	pop af
ENDM


; Prints char_nc if C flag is clear,
; char_c if C flag is set.
; Preserved: AF, BC, DE, HL
MACRO print_nc
	push af
	ld a, \1
	jr nz, PrintNC\@
	ld a, \2
PrintNC\@:
	call PrintChar
	pop af
ENDM


; Prints A as 2 decimal digits
; Preserved: AF, BC, DE, HL
PrintDec2:
	push af
	push bc
	jr PrintDec.tens


; Prints A as 1-3 digit decimal value
; Preserved: AF, BC, DE, HL
PrintDec:
	push af
	push bc

	cp 10
	jr c, .ones
	ld c, 100
	cp c
	call nc, .digit
.tens:
	ld c, 10
	call .digit
.ones:
	add '0'
	call PrintChar

	pop bc
	pop af
	ret

.digit:
	ld b, '0'-1
.subtract:
	inc b
	sub c
	jr nc, .subtract
	add c

	ld c, a
	ld a, b
	call PrintChar
	ld a, c
	ret
