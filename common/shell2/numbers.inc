; Prints char_nz if Z flag is clear,
; char_z if Z flag is set.
; Preserved: AF, BC, DE, HL
MACRO print_nz
     push af
     ld   a,\1
     jr   nz,PrintNZ\@
     ld   a,\2
PrintNZ\@:
     call PrintChar
     pop  af
ENDM

; Prints char_nc if C flag is clear,
; char_c if C flag is set.
; Preserved: AF, BC, DE, HL
MACRO print_nc
     push af
     ld   a,\1
     jr   nz,PrintNC\@
     ld   a,\2
PrintNC\@:
     call PrintChar
     pop  af
ENDM
