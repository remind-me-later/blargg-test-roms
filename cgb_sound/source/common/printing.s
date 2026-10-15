; Prints char without updating checksum
; Preserved: BC, DE, HL
;print_char_nocrc (defined by user)

; Prints character and updates checksum UNLESS
; it's a newline.
; Preserved: AF, BC, DE, HL
print_char:
     push af
     cp   newline
     call nz,update_crc
     call print_char_nocrc
     pop  af
     ret

; Prints space. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
print_space:
     push af
     ld   a,' '
     call print_char_nocrc
     pop  af
     ret

; Advances to next line. Does NOT update checksum.
; Preserved: AF, BC, DE, HL
print_newline:
     push af
     ld   a,newline
     call print_char_nocrc
     pop  af
     ret

print_str_:
     pop  hl
     call print_str_hl
     jp   hl

; Prints zero-terminated string pointed to by HL.
; On return, HL points to byte AFTER zero terminator.
; Preserved: AF, BC, DE
print_str_hl:
     push af
     jr   :++
:    call print_char
:    ld   a,[hli]
     or   a
     jr   nz,:--
     pop  af
     ret
