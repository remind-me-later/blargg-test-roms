; Scrolling text console (constants)

; Console is 20x18 characters. Buffers lines, so
; output doesn't appear until a newline or flush.
; If scrolling isn't supported (i.e. SCY is treated
; as if always zero), the first 18 lines will
; still print properly). Also works properly if
; LY isn't supported (always reads back as the same
; value).

DEF CONSOLE_WIDTH EQU 20

; Its variables, wConsoleBuf and the following, are in variables.inc

