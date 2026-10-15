; Fast table-based CRC-32

; The tables are 256-byte aligned, and go after the variables of checksums.s
PUSHS UNION "CRC tables", WRAMX[(wChecksumVariablesEnd + $FF) & $FF00], BANK[1]
wCrcTables:     ds $400
wCrcTablesEnd:
POPS


; Initializes fast CRC tables and resets checksum.
; Time: 47 msec
init_crc_fast:
     ld   l,0
.next:
     xor  a
     ld   c,a
     ld   d,a
     ld   e,l

     ld   h,8
.bit:
     rra
     rr   c
     rr   d
     rr   e
     jr   nc,.next_bit
     xor  $ED
     ld   b,a
     ld   a,c
     xor  $B8
     ld   c,a
     ld   a,d
     xor  $83
     ld   d,a
     ld   a,e
     xor  $20
     ld   e,a
     ld   a,b

.next_bit:
     dec  h
     jr   nz,.bit

     ld   h,HIGH(wCrcTables)
     ld   [hl],e
     inc  h
     ld   [hl],d
     inc  h
     ld   [hl],c
     inc  h
     ld   [hl],a

     inc  l
     jr   nz,.next

     jp   init_crc


; Faster version of update_crc
; Preserved: BC, DE
; Time: 50 cycles (including CALL)
update_crc_fast:

; Fastest inline macro version of update_crc_fast
; Time: 40 cycles
; Size: 28 bytes
MACRO update_crc_fast_inline
     ld   l,a            ; 1
     lda  hChecksum       ; 3
     xor  l              ; 1
     ld   l,a            ; 1
     ld   h,HIGH(wCrcTables)  ; 2

     lda  hChecksum+1     ; 3
     xor  [hl]           ; 2
     inc  h              ; 1
     sta  hChecksum       ; 3

     lda  hChecksum+2     ; 3
     xor  [hl]           ; 2
     inc  h              ; 1
     sta  hChecksum+1     ; 3

     lda  hChecksum+3     ; 3
     xor  [hl]           ; 2
     inc  h              ; 1
     sta  hChecksum+2     ; 3

     ld   a,[hl]         ; 2
     sta  hChecksum+3     ; 3
ENDM
     update_crc_fast_inline
     ret
