; Scrolling text console

; Console is 20x18 characters. Buffers lines, so
; output doesn't appear until a newline or flush.
; If scrolling isn't supported (i.e. SCY is treated
; as if always zero), the first 18 lines will
; still print properly). Also works properly if
; LY isn't supported (always reads back as the same
; value).

DEF console_width = 20

DEF console_buf = bss+0
DEF console_pos = bss+console_width
DEF console_mode = bss+console_width+1
DEF console_scroll = bss+console_width+2
DEF bss = bss+console_width+3
