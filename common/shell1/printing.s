; Main printing routine that checksums and
; prints to output device

; Character that does equivalent of print_newline
DEF NEWLINE EQU 10

; Prints char without updating checksum
; Preserved: BC, DE, HL
; (wPrintCharNoCrc, in RAM, is a JP to the print routine)


; Initializes printing. HL = print routine
init_printing:
     ld   a,l
     ld   [wPrintCharNoCrc+1],a
     ld   a,h
     ld   [wPrintCharNoCrc+2],a
     jr   show_printing


; Hides/shows further printing
; Preserved: BC, DE, HL
hide_printing:
     ld   a,$C9     ; RET
     jr   show_printing.set
show_printing:
     ld   a,$C3     ; JP (nn)
.set:
     ld   [wPrintCharNoCrc],a
     ret


; Prints character and updates checksum UNLESS
; it's a newline.
; Preserved: AF, BC, DE, HL
print_char:
     push af
     cp   NEWLINE
     call nz,update_crc
     call wPrintCharNoCrc
     pop  af
     ret


; Prints space. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
print_space:
     push af
     ld   a,' '
     call wPrintCharNoCrc
     pop  af
     ret


; Advances to next line. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
print_newline:
     push af
     ld   a,NEWLINE
     call wPrintCharNoCrc
     pop  af
     ret


; Prints immediate string
; Preserved: AF, BC, DE, HL
MACRO print_str ; string,string2
     push hl
     call print_str_
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

print_str_:
     pop  hl
     call print_str_hl
     jp   hl


; Prints zero-terminated string pointed to by HL.
; On return, HL points to byte AFTER zero terminator.
; Preserved: AF, BC, DE
print_str_hl:
     push af
     jr   .next
.print:
     call print_char
.next:
     ld   a,[hli]
     or   a
     jr   nz,.print
     pop  af
     ret
