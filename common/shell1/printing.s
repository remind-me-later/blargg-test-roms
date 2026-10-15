; Main printing routine that checksums and
; prints to output device

; Character that does equivalent of PrintNewline
DEF NEWLINE EQU 10

; Prints char without updating checksum
; Preserved: BC, DE, HL
; (wPrintCharNoCrc, in RAM, is a JP to the print routine)


; Initializes printing. HL = print routine
InitPrinting:
	ld   a,l
	ld   [wPrintCharNoCrc+1],a
	ld   a,h
	ld   [wPrintCharNoCrc+2],a
	jr   ShowPrinting


; Hides/shows further printing
; Preserved: BC, DE, HL
HidePrinting:
	ld   a,$C9     ; RET
	jr   ShowPrinting.set
ShowPrinting:
	ld   a,$C3     ; JP (nn)
.set:
	ld   [wPrintCharNoCrc],a
	ret


; Prints character and updates checksum UNLESS
; it's a newline.
; Preserved: AF, BC, DE, HL
PrintChar:
	push af
	cp   NEWLINE
	call nz,UpdateCRC
	call wPrintCharNoCrc
	pop  af
	ret


; Prints space. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
PrintSpace:
	push af
	ld   a,' '
	call wPrintCharNoCrc
	pop  af
	ret


; Advances to next line. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
PrintNewline:
	push af
	ld   a,NEWLINE
	call wPrintCharNoCrc
	pop  af
	ret


; Prints immediate string
; Preserved: AF, BC, DE, HL
MACRO print_str ; string,string2
	push hl
	call PrintStr_
	db \1
	IF _NARG > 1
		db \2
	ENDC
	IF _NARG > 2
		db \3
	ENDC
	db 0
	pop  hl
ENDM

PrintStr_:
	pop  hl
	call PrintStrHL
	jp   hl


; Prints zero-terminated string pointed to by HL.
; On return, HL points to byte AFTER zero terminator.
; Preserved: AF, BC, DE
PrintStrHL:
	push af
	jr   .next
.print:
	call PrintChar
.next:
	ld   a,[hli]
	or   a
	jr   nz,.print
	pop  af
	ret
