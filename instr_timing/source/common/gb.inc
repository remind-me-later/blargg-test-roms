; Game Boy hardware addresses

; Memory
DEF VRAM_START = $8000 ; video memory
DEF TILES = $8000 ; tile images
DEF BGMAP0 = $9800 ; first 32x32 tilemap
DEF BGMAP1 = $9C00 ; second 32x32 tilemap
DEF WRAM = $C000 ; internal memory
DEF OAM_START = $FE00 ; sprite memory
DEF HRAM_START = $FF80 ; fast memory for LDH

DEF P1 = $FF00

; Game link I/O
DEF SB = $FF01
DEF SC = $FF02

; Interrupts
DEF rDIV = $FF04
DEF TIMA = $FF05
DEF TMA = $FF06
DEF TAC = $FF07
DEF rIF = $FF0F
DEF IE = $FFFF

; LCD registers
DEF LCDC = $FF40 ; control
DEF STAT = $FF41 ; status
DEF SCY = $FF42 ; scroll Y
DEF SCX = $FF43 ; scroll X
DEF LY = $FF44 ; current Y being rendered
DEF BGP = $FF47

DEF KEY1 = $FF4D ; for changing CPU speed
DEF VBK = $FF4F

; Sound registers
DEF NR10 = $FF10
DEF NR11 = $FF11
DEF NR12 = $FF12
DEF NR13 = $FF13
DEF NR14 = $FF14

DEF NR21 = $FF16
DEF NR22 = $FF17
DEF NR23 = $FF18
DEF NR24 = $FF19

DEF NR30 = $FF1A
DEF NR31 = $FF1B
DEF NR32 = $FF1C
DEF NR33 = $FF1D
DEF NR34 = $FF1E

DEF NR41 = $FF20
DEF NR42 = $FF21
DEF NR43 = $FF22
DEF NR44 = $FF23

DEF NR50 = $FF24
DEF NR51 = $FF25
DEF NR52 = $FF26

DEF WAVE = $FF30
