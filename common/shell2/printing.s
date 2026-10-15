; Prints char without updating checksum
; Preserved: BC, DE, HL
;PrintCharNoCRC (defined by user)

; Prints character and updates checksum UNLESS
; it's a newline.
; Preserved: AF, BC, DE, HL
PrintChar:
     push af
     cp   NEWLINE
     call nz,UpdateCRC
     call PrintCharNoCRC
     pop  af
     ret

; Prints space. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
PrintSpace:
     push af
     ld   a,' '
     call PrintCharNoCRC
     pop  af
     ret

; Advances to next line. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
PrintNewline:
     push af
     ld   a,NEWLINE
     call PrintCharNoCRC
     pop  af
     ret

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
