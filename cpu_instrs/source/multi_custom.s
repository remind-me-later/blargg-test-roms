; RST and interrupt handlers: INC A, RET at every vector from $00 to $58

PUSHS
SECTION "vector handlers", ROM0[$00]
REPT 11
     inc  a
     ret
     ds   6,0
ENDR
     inc  a
     ret
POPS
