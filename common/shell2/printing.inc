; Main printing routine that checksums and
; prints to output device

; Character that does equivalent of PrintNewline
DEF NEWLINE EQU 10

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
	pop hl
ENDM
