; Diagnostic and testing utilities

; Sets test code and optional error text.
; The text can be given as several strings, which are stored one after another.
; Preserved: AF, BC, DE, HL
MACRO set_test ; code[,text[,text2[,text3]]]
     push hl
     call SetTest_
     jr   .setTest\@
     db \1
     IF _NARG > 1
          db \2
     ENDC
     IF _NARG > 2
          db \3
     ENDC
     IF _NARG > 3
          db \4
     ENDC
     db 0
.setTest\@:
     pop  hl
ENDM

; If checksum doesn't match expected, reports failed test.
; Passing 0 just prints checksum. Clears checksum afterwards.
MACRO check_crc
     IF (\1) == 0
          call PrintNewline
          call PrintCRC
     ELSE
          ld   bc,((\1) >>> 16) ^ $FFFF
          ld   de,((\1) & $FFFF) ^ $FFFF
          call CheckCRC_
     ENDC
ENDM

; Checks CRC, differing based on DMG or CGB build
MACRO? check_crc_dmg_cgb
     IF DEF(REQUIRE_DMG)
          check_crc \1
     ELSE
          IF DEF(REQUIRE_CGB)
               check_crc \2
          ELSE
               FAIL "CGB or DMG must be specified"
          ENDC
     ENDC
ENDM

; Updates checksum with bytes from addr to addr+size-1
MACRO checksum_mem
     ld   hl,\1
     ld   bc,\2
     call ChecksumMem_
ENDM
